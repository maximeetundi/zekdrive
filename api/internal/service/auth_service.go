package service

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"github.com/zekdrive/api/internal/config"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type AuthService interface {
	Register(ctx context.Context, req *domain.RegisterRequest) (*domain.User, error)
	Login(ctx context.Context, req *domain.LoginRequest) (*domain.LoginResponse, error)
	RefreshToken(ctx context.Context, refreshToken string) (*domain.LoginResponse, error)
	ValidateToken(tokenStr string, isRefresh bool) (*jwt.Token, error)
	SendWhatsAppOTP(ctx context.Context, req *domain.SendWhatsAppOTPRequest) error
	VerifyWhatsAppOTP(ctx context.Context, req *domain.VerifyWhatsAppOTPRequest) (*domain.LoginResponse, error)
}

type authClaims struct {
	UserID uuid.UUID       `json:"user_id"`
	Email  string          `json:"email"`
	Role   domain.UserRole `json:"role"`
	jwt.RegisteredClaims
}

type authService struct {
	cfg         *config.Config
	userRepo    domain.UserRepository
	driverRepo  domain.DriverRepository
	redis       *database.RedisClient
	settingRepo domain.SettingRepository
}

func NewAuthService(cfg *config.Config, userRepo domain.UserRepository, driverRepo domain.DriverRepository, redis *database.RedisClient, settingRepo domain.SettingRepository) AuthService {
	return &authService{
		cfg:         cfg,
		userRepo:    userRepo,
		driverRepo:  driverRepo,
		redis:       redis,
		settingRepo: settingRepo,
	}
}

func (s *authService) Register(ctx context.Context, req *domain.RegisterRequest) (*domain.User, error) {
	// Check if email already exists
	existing, err := s.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, errors.New("email already in use")
	}

	// Check if phone already exists
	existingPhone, err := s.userRepo.GetByPhone(ctx, req.Phone)
	if err != nil {
		return nil, err
	}
	if existingPhone != nil {
		return nil, errors.New("phone number already in use")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	u := &domain.User{
		ID:              uuid.New(),
		Name:            req.Name,
		Email:           req.Email,
		Password:        string(hashedPassword),
		Phone:           req.Phone,
		Role:            req.Role,
		IsPhoneVerified: false,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	if err := s.userRepo.Create(ctx, u); err != nil {
		return nil, err
	}

	// Auto-create matching driver profile if role is driver or pro
	if req.Role == domain.RoleDriver || req.Role == domain.RolePro {
		licenseNum := req.IdentificationNumber
		if licenseNum == "" {
			licenseNum = req.Phone
		}

		d := &domain.Driver{
			ID:            uuid.New(),
			UserID:        u.ID,
			LicenseNumber: licenseNum,
			Status:        domain.DriverStatusOffline,
			Rating:        5.00,
			Country:       "",
			KycStatus:     "pending",
			KycDocument:   "",
			CreatedAt:     now,
			UpdatedAt:     now,
		}

		_ = s.driverRepo.Create(ctx, d)
	}

	return u, nil
}

func (s *authService) Login(ctx context.Context, req *domain.LoginRequest) (*domain.LoginResponse, error) {
	var u *domain.User
	var err error

	identifier := req.Email
	if identifier == "" {
		identifier = req.PhoneOrEmail
	}

	if strings.Contains(identifier, "@") {
		u, err = s.userRepo.GetByEmail(ctx, identifier)
	} else {
		u, err = s.userRepo.GetByPhone(ctx, identifier)
	}

	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, errors.New("invalid email/phone or password")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid email or password")
	}

	accessToken, err := s.generateToken(u, false)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateToken(u, true)
	if err != nil {
		return nil, err
	}

	return &domain.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         *u,
	}, nil
}

func (s *authService) RefreshToken(ctx context.Context, tokenStr string) (*domain.LoginResponse, error) {
	token, err := s.ValidateToken(tokenStr, true)
	if err != nil || !token.Valid {
		return nil, errors.New("invalid refresh token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, errors.New("invalid token claims")
	}

	userIDStr, err := claims.GetSubject()
	if err != nil || userIDStr == "" {
		return nil, errors.New("invalid subject in claims")
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return nil, errors.New("invalid user id in claims")
	}

	u, err := s.userRepo.GetByID(ctx, userID)
	if err != nil || u == nil {
		return nil, errors.New("user not found")
	}

	accessToken, err := s.generateToken(u, false)
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := s.generateToken(u, true)
	if err != nil {
		return nil, err
	}

	return &domain.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		User:         *u,
	}, nil
}

func (s *authService) ValidateToken(tokenStr string, isRefresh bool) (*jwt.Token, error) {
	secret := s.cfg.JWTSecret
	if isRefresh {
		secret = s.cfg.JWTRefreshSecret
	}

	return jwt.ParseWithClaims(tokenStr, jwt.MapClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(secret), nil
	})
}

func (s *authService) generateToken(u *domain.User, isRefresh bool) (string, error) {
	secret := s.cfg.JWTSecret
	expiry := time.Duration(s.cfg.JWTAccessExpiryMin) * time.Minute

	if isRefresh {
		secret = s.cfg.JWTRefreshSecret
		expiry = time.Duration(s.cfg.JWTRefreshExpiryDays) * 24 * time.Hour
	}

	claims := authClaims{
		UserID: u.ID,
		Email:  u.Email,
		Role:   u.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   u.ID.String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

func (s *authService) getAuthConfig(ctx context.Context) map[string]interface{} {
	cacheKey := "config:auth"
	if cachedVal, err := s.redis.Get(ctx, cacheKey).Result(); err == nil && cachedVal != "" {
		var cachedConfig map[string]interface{}
		if err := json.Unmarshal([]byte(cachedVal), &cachedConfig); err == nil {
			return cachedConfig
		}
	}

	var configMap map[string]interface{}
	setting, err := s.settingRepo.GetByKey(ctx, "auth_config")
	if err == nil && setting != nil {
		if cm, ok := setting.LiveValues.(map[string]interface{}); ok {
			configMap = cm
		}
	}

	if configMap == nil {
		// Return defaults matching config/environment variables
		configMap = map[string]interface{}{
			"whatsapp_url":        s.cfg.WhatsAppURL,
			"whatsapp_session_id": s.cfg.WhatsAppSessionID,
			"whatsapp_api_key":    s.cfg.WhatsAppAPIKey,
			"sms_enabled":         false,
			"whatsapp_enabled":    true,
		}
	}

	// Cache in Redis for 1 minute to make future lookups instant
	if configBytes, err := json.Marshal(configMap); err == nil {
		_ = s.redis.Set(ctx, cacheKey, string(configBytes), 1*time.Minute).Err()
	}

	return configMap
}

func (s *authService) SendWhatsAppOTP(ctx context.Context, req *domain.SendWhatsAppOTPRequest) error {
	// Clean phone number format
	phoneClean := req.Phone
	phoneClean = strings.TrimPrefix(phoneClean, "+")
	phoneClean = strings.ReplaceAll(phoneClean, " ", "")
	phoneClean = strings.ReplaceAll(phoneClean, "-", "")

	// Check if user exists by phone (with/without '+' prefix and clean format)
	u, err := s.userRepo.GetByPhone(ctx, req.Phone)
	if err != nil {
		return err
	}
	if u == nil {
		u, err = s.userRepo.GetByPhone(ctx, phoneClean)
		if err != nil {
			return err
		}
	}
	if u == nil {
		u, err = s.userRepo.GetByPhone(ctx, "+"+phoneClean)
		if err != nil {
			return err
		}
	}

	if u == nil {
		return errors.New("numéro de téléphone non enregistré")
	}

	// Generate 5-digit OTP
	code := fmt.Sprintf("%05d", rand.Intn(100000))
	log.Printf("[OTP] Generated WhatsApp OTP code %s for phone %s", code, phoneClean)

	// Store OTP in redis with a 5 minutes expiry
	key := fmt.Sprintf("otp:whatsapp:%s", phoneClean)
	err := s.redis.Set(ctx, key, code, 5*time.Minute).Err()
	if err != nil {
		return fmt.Errorf("failed to save OTP in redis: %w", err)
	}

	authCfg := s.getAuthConfig(ctx)

	// Prepare payload for OpenWA
	whatsappPayload := map[string]string{
		"chatId": fmt.Sprintf("%s@c.us", phoneClean),
		"text":   fmt.Sprintf("ZekDrive: Votre code de validation est %s. Il expire dans 5 minutes.", code),
	}

	url := fmt.Sprintf("%s/api/sessions/%s/messages/send-text", authCfg["whatsapp_url"], authCfg["whatsapp_session_id"])
	payloadBytes, err := json.Marshal(whatsappPayload)
	if err != nil {
		return err
	}

	httpReq, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return err
	}
	httpReq.Header.Set("Content-Type", "application/json")
	if apiKey, ok := authCfg["whatsapp_api_key"].(string); ok && apiKey != "" {
		httpReq.Header.Set("x-api-key", apiKey)
	}

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(httpReq)
	if err != nil {
		log.Printf("[OTP] Warning: Failed to send OTP via WhatsApp: %v. The code is still saved in Redis.", err)
		return nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusOK {
		var errBody map[string]interface{}
		_ = json.NewDecoder(resp.Body).Decode(&errBody)
		log.Printf("[OTP] Warning: OpenWA service returned error (status %d): %v. The code is still saved in Redis.", resp.StatusCode, errBody)
		return nil
	}

	return nil
}

func (s *authService) VerifyWhatsAppOTP(ctx context.Context, req *domain.VerifyWhatsAppOTPRequest) (*domain.LoginResponse, error) {
	phoneClean := req.Phone
	phoneClean = strings.TrimPrefix(phoneClean, "+")
	phoneClean = strings.ReplaceAll(phoneClean, " ", "")
	phoneClean = strings.ReplaceAll(phoneClean, "-", "")

	key := fmt.Sprintf("otp:whatsapp:%s", phoneClean)
	storedCode, err := s.redis.Get(ctx, key).Result()
	if err != nil {
		return nil, errors.New("code expiré ou invalide")
	}

	if storedCode != req.Code {
		return nil, errors.New("code de validation incorrect")
	}

	// Delete from redis after successful verification
	s.redis.Del(ctx, key)

	// Fetch or create user
	u, err := s.userRepo.GetByPhone(ctx, req.Phone)
	if err != nil {
		return nil, err
	}

	if u == nil {
		role := req.Role
		if role == "" {
			role = domain.RoleRider
		}
		name := req.Name
		if name == "" {
			if len(req.Phone) > 4 {
				name = fmt.Sprintf("User_%s", req.Phone[len(req.Phone)-4:])
			} else {
				name = "User_" + req.Phone
			}
		}
		email := fmt.Sprintf("%s@zekdrive.otp", phoneClean)

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(uuid.New().String()), bcrypt.DefaultCost)
		if err != nil {
			return nil, err
		}

		now := time.Now()
		u = &domain.User{
			ID:              uuid.New(),
			Name:            name,
			Email:           email,
			Password:        string(hashedPassword),
			Phone:           req.Phone,
			Role:            role,
			IsPhoneVerified: true,
			CreatedAt:       now,
			UpdatedAt:       now,
		}

		if err := s.userRepo.Create(ctx, u); err != nil {
			return nil, err
		}

		// Auto-create matching driver profile if role is driver or pro
		if u.Role == domain.RoleDriver || u.Role == domain.RolePro {
			d := &domain.Driver{
				ID:            uuid.New(),
				UserID:        u.ID,
				LicenseNumber: u.Phone,
				Status:        domain.DriverStatusOffline,
				Rating:        5.00,
				Country:       "",
				KycStatus:     "pending",
				KycDocument:   "",
				CreatedAt:     now,
				UpdatedAt:     now,
			}
			_ = s.driverRepo.Create(ctx, d)
		}
	} else if !u.IsPhoneVerified {
		u.IsPhoneVerified = true
		u.UpdatedAt = time.Now()
		if err := s.userRepo.Update(ctx, u); err != nil {
			return nil, err
		}
	}

	accessToken, err := s.generateToken(u, false)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateToken(u, true)
	if err != nil {
		return nil, err
	}

	return &domain.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         *u,
	}, nil
}
