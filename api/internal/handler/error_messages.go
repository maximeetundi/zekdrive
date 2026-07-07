package handler

import (
	"strings"

	"github.com/go-playground/validator/v10"
)

// friendlyValidationError convertit les erreurs de validation technique
// du package validator en messages lisibles par l'utilisateur.
func friendlyValidationError(err error) string {
	if err == nil {
		return ""
	}

	validationErrors, ok := err.(validator.ValidationErrors)
	if !ok {
		return humanizeError(err.Error())
	}

	messages := []string{}
	for _, fe := range validationErrors {
		messages = append(messages, fieldErrorMessage(fe))
	}

	if len(messages) == 1 {
		return messages[0]
	}
	return strings.Join(messages, ". ")
}

// fieldErrorMessage traduit une erreur de champ spécifique en message clair.
func fieldErrorMessage(fe validator.FieldError) string {
	field := strings.ToLower(fe.Field())
	tag := fe.Tag()

	switch field {
	case "name", "firstname", "lastname", "first_name", "last_name":
		switch tag {
		case "required":
			return "Le nom est requis"
		case "min":
			return "Le nom doit contenir au moins 2 caractères"
		case "max":
			return "Le nom est trop long"
		}
	case "email":
		switch tag {
		case "required":
			return "L'adresse email est requise"
		case "email":
			return "L'adresse email n'est pas valide"
		}
	case "phone":
		switch tag {
		case "required":
			return "Le numéro de téléphone est requis"
		case "min":
			return "Le numéro de téléphone est trop court"
		case "max":
			return "Le numéro de téléphone est trop long"
		}
	case "password":
		switch tag {
		case "required":
			return "Le mot de passe est requis"
		case "min":
			return "Le mot de passe doit contenir au moins 6 caractères"
		}
	case "pickuplat", "pickup_lat":
		if tag == "required" || tag == "latitude" {
			return "La position de départ est invalide"
		}
	case "pickuplng", "pickup_lng":
		if tag == "required" || tag == "longitude" {
			return "La position de départ est invalide"
		}
	case "dropofflat", "dropoff_lat":
		if tag == "required" || tag == "latitude" {
			return "La destination est invalide"
		}
	case "dropofflng", "dropoff_lng":
		if tag == "required" || tag == "longitude" {
			return "La destination est invalide"
		}
	case "pickupaddress", "pickup_address":
		return "L'adresse de départ est requise"
	case "dropoffaddress", "dropoff_address":
		return "L'adresse de destination est requise"
	case "vehicletype", "vehicle_type":
		switch tag {
		case "required":
			return "Le type de véhicule est requis"
		case "oneof":
			return "Type de véhicule non reconnu"
		}
	case "role":
		if tag == "oneof" || tag == "required" {
			return "Type de compte invalide"
		}
	case "recipientname", "recipient_name":
		return "Le nom du destinataire est requis"
	case "recipientphone", "recipient_phone":
		return "Le téléphone du destinataire est requis"
	case "packagedetails", "package_details":
		return "La description du colis est requise"
	case "amount":
		switch tag {
		case "required":
			return "Le montant est requis"
		case "min", "gt":
			return "Le montant doit être supérieur à 0"
		}
	case "type":
		if tag == "oneof" || tag == "required" {
			return "Type de service non reconnu"
		}
	case "status":
		if tag == "oneof" || tag == "required" {
			return "Statut invalide"
		}
	}

	// Fallback générique lisible
	switch tag {
	case "required":
		return "Un champ obligatoire est manquant"
	case "email":
		return "Format d'email invalide"
	case "min":
		return "La valeur saisie est trop courte"
	case "max":
		return "La valeur saisie est trop longue"
	case "oneof":
		return "Valeur non autorisée"
	case "latitude":
		return "Coordonnée GPS invalide"
	case "longitude":
		return "Coordonnée GPS invalide"
	}

	return "Données invalides, veuillez vérifier votre saisie"
}

// humanizeError nettoie les erreurs techniques brutes.
func humanizeError(raw string) string {
	lower := strings.ToLower(raw)
	switch {
	case strings.Contains(lower, "duplicate") || strings.Contains(lower, "already in use") || strings.Contains(lower, "already exists"):
		if strings.Contains(lower, "phone") {
			return "Ce numéro de téléphone est déjà utilisé"
		}
		if strings.Contains(lower, "email") {
			return "Cette adresse email est déjà utilisée"
		}
		return "Ce compte existe déjà"
	case strings.Contains(lower, "not found"):
		return "Élément introuvable"
	case strings.Contains(lower, "invalid") && strings.Contains(lower, "password"):
		return "Mot de passe ou identifiant incorrect"
	case strings.Contains(lower, "unauthorized") || strings.Contains(lower, "forbidden"):
		return "Vous n'avez pas accès à cette ressource"
	case strings.Contains(lower, "connection refused") || strings.Contains(lower, "timeout"):
		return "Service temporairement indisponible, réessayez"
	case strings.Contains(lower, "cannot parse") || strings.Contains(lower, "unmarshal"):
		return "Format de données invalide"
	default:
		return raw
	}
}
