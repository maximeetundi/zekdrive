package config

import (
	"log"
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	Port string `mapstructure:"PORT"`
	Env  string `mapstructure:"ENV"`

	DBHost    string `mapstructure:"DB_HOST"`
	DBPort    string `mapstructure:"DB_PORT"`
	DBUser    string `mapstructure:"DB_USER"`
	DBPassword string `mapstructure:"DB_PASSWORD"`
	DBName    string `mapstructure:"DB_NAME"`
	DBSSLMode string `mapstructure:"DB_SSLMODE"`

	RedisHost     string `mapstructure:"REDIS_HOST"`
	RedisPort     string `mapstructure:"REDIS_PORT"`
	RedisPassword string `mapstructure:"REDIS_PASSWORD"`
	RedisDB       int    `mapstructure:"REDIS_DB"`

	JWTSecret             string `mapstructure:"JWT_SECRET"`
	JWTRefreshSecret      string `mapstructure:"JWT_REFRESH_SECRET"`
	JWTAccessExpiryMin    int    `mapstructure:"JWT_ACCESS_EXPIRY_MINUTES"`
	JWTRefreshExpiryDays  int    `mapstructure:"JWT_REFRESH_EXPIRY_DAYS"`

	WhatsAppURL       string `mapstructure:"WHATSAPP_URL"`
	WhatsAppAPIKey    string `mapstructure:"WHATSAPP_API_KEY"`
	WhatsAppSessionID string `mapstructure:"WHATSAPP_SESSION_ID"`

	NominatimURL string `mapstructure:"NOMINATIM_URL"`
	OSRMURL      string `mapstructure:"OSRM_URL"`
}

func LoadConfig() (*Config, error) {
	viper.AddConfigPath(".")
	viper.SetConfigFile(".env")
	viper.AutomaticEnv()

	// Replace dot with underscores in env vars
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// Default configurations
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("ENV", "development")
	viper.SetDefault("DB_HOST", "localhost")
	viper.SetDefault("DB_PORT", "5432")
	viper.SetDefault("DB_USER", "postgres")
	viper.SetDefault("DB_PASSWORD", "postgres")
	viper.SetDefault("DB_NAME", "zekdrive")
	viper.SetDefault("DB_SSLMODE", "disable")
	viper.SetDefault("REDIS_HOST", "localhost")
	viper.SetDefault("REDIS_PORT", "6379")
	viper.SetDefault("REDIS_PASSWORD", "")
	viper.SetDefault("REDIS_DB", 0)
	viper.SetDefault("JWT_ACCESS_EXPIRY_MINUTES", 15)
	viper.SetDefault("JWT_REFRESH_EXPIRY_DAYS", 7)
	viper.SetDefault("WHATSAPP_URL", "http://openwa-api:2785")
	viper.SetDefault("WHATSAPP_API_KEY", "owa_k1_eee56788a1354467c70629006b57db1e97c8f4988d4f8bab1cb415faf2067d5e")
	viper.SetDefault("WHATSAPP_SESSION_ID", "bdcc38d6-840f-4fce-b0b6-8365063d7fc4")
	viper.SetDefault("NOMINATIM_URL", "https://nominatim.openstreetmap.org")
	viper.SetDefault("OSRM_URL", "https://router.project-osrm.org")

	if err := viper.ReadInConfig(); err != nil {
		log.Println("No .env file found. Using environment variables.")
	}

	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		return nil, err
	}

	redisURL := viper.GetString("REDIS_URL")
	if redisURL != "" {
		u := strings.TrimPrefix(redisURL, "redis://")
		if idx := strings.Index(u, "@"); idx != -1 {
			credentials := u[:idx]
			u = u[idx+1:]
			if passIdx := strings.Index(credentials, ":"); passIdx != -1 {
				config.RedisPassword = credentials[passIdx+1:]
			} else {
				config.RedisPassword = credentials
			}
		}
		if strings.Contains(u, ":") {
			parts := strings.SplitN(u, ":", 2)
			config.RedisHost = parts[0]
			portPart := parts[1]
			if slashIdx := strings.Index(portPart, "/"); slashIdx != -1 {
				config.RedisPort = portPart[:slashIdx]
			} else {
				config.RedisPort = portPart
			}
		} else {
			config.RedisHost = u
			config.RedisPort = "6379"
		}
	}

	return &config, nil
}
