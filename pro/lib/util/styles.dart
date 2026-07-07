import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── ZekDrive Design System — Typography ────────────────────────────────────

const sfProLight = TextStyle(
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w300,
  letterSpacing: 0.1,
);

const textRegular = TextStyle(
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w400,
  letterSpacing: 0.1,
);

const textMedium = TextStyle(
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w500,
  letterSpacing: 0.1,
);

const textSemiBold = TextStyle(
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);

const textBold = TextStyle(
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w700,
  letterSpacing: 0.1,
);

const textHeavy = TextStyle(
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w900,
  letterSpacing: 0.1,
);

// ─── Shadows ─────────────────────────────────────────────────────────────────

List<BoxShadow> get cardShadow => Get.isDarkMode
    ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, spreadRadius: 0, offset: const Offset(0, 4))]
    : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, spreadRadius: 0, offset: const Offset(0, 4))];

List<BoxShadow> get searchBoxShadow => Get.isDarkMode
    ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, spreadRadius: 0, offset: const Offset(0, 2))]
    : [BoxShadow(color: const Color(0xFF14B19E).withOpacity(0.12), blurRadius: 8, spreadRadius: 0, offset: const Offset(0, 2))];

List<BoxShadow> get shadow => [
  BoxShadow(
    color: Get.isDarkMode ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.07),
    blurRadius: 10,
    spreadRadius: 0,
    offset: const Offset(0, 3),
  )
];

List<BoxShadow> get floatShadow => [
  BoxShadow(
    color: Get.isDarkMode ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.12),
    blurRadius: 20,
    spreadRadius: 0,
    offset: const Offset(0, 8),
  )
];

// ─── Gradients ────────────────────────────────────────────────────────────────

const brandGradient = LinearGradient(
  colors: [Color(0xFF14B19E), Color(0xFF0E8A7A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const darkBrandGradient = LinearGradient(
  colors: [Color(0xFF0A1628), Color(0xFF1C2333)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
