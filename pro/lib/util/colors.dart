import 'package:flutter/material.dart';

// ─── ZekDrive Brand Color Palette ────────────────────────────────────────────
// Source unique des couleurs. Importé par light_theme.dart, dark_theme.dart
// et tous les widgets qui ont besoin de couleurs nommées.

// ── Couleurs primaires (Teal ZekDrive)
const kBrandTeal      = Color(0xFF14B19E);
const kBrandTealDark  = Color(0xFF0E8A7A);
const kBrandTealLight = Color(0xFFE6F7F5);

// Aliases utilisés dans light_theme.dart / dark_theme.dart
const kBrand      = kBrandTeal;
const kBrandDark  = kBrandTealDark;
const kBrandLight = kBrandTealLight;

// ── Couleurs sémantiques
const kSuccess       = Color(0xFF10B981); // Vert succès
const kSuccessGreen  = kSuccess;          // Alias
const kError         = Color(0xFFEF4444); // Rouge erreur
const kDangerRed     = kError;            // Alias
const kWarning       = Color(0xFFF59E0B); // Orange avertissement
const kWarningAmber  = kWarning;          // Alias
const kInfo          = Color(0xFF3B82F6); // Bleu info
const kInfoBlue      = kInfo;             // Alias
const kPurple        = Color(0xFF8B5CF6); // Violet (niveau/récompenses)
const kNavy          = Color(0xFF1E3A5F); // Bleu marine (dark elements)

// ── Gradients
const kBrandGradient = LinearGradient(
  colors: [kBrandTeal, kBrandTealDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kDarkBgGradient = LinearGradient(
  colors: [Color(0xFF0A1628), Color(0xFF1C2333)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
