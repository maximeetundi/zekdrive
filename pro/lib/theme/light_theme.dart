import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/colors.dart';


// Pro app exposes a ThemeData value (not a function)
final ThemeData lightTheme = ThemeData(
  fontFamily: 'SFProText',
  useMaterial3: false,
  brightness: Brightness.light,

  primaryColor: kBrand,
  primaryColorDark: kBrandDark,
  scaffoldBackgroundColor: const Color(0xFFF4F6F9),
  canvasColor: const Color(0xFFF4F6F9),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFE5E7EB),
  hintColor: const Color(0xFF9CA3AF),
  disabledColor: const Color(0xFFD1D5DB),
  shadowColor: Colors.black.withOpacity(0.06),
  dialogBackgroundColor: Colors.white,

  colorScheme: const ColorScheme.light(
    primary:              kBrand,
    onPrimary:            Colors.white,
    primaryContainer:     kBrandLight,
    onPrimaryContainer:   kBrandDark,
    secondary:            Color(0xFF1E3A5F),
    onSecondary:          Colors.white,
    secondaryContainer:   Color(0xFFEEF2FF),
    onSecondaryContainer: Color(0xFF1E3A5F),
    tertiary:             kSuccess,
    onTertiary:           Colors.white,
    tertiaryContainer:    Color(0xFFD1FAE5),
    onTertiaryContainer:  Color(0xFF065F46),
    error:                kError,
    onError:              Colors.white,
    errorContainer:       Color(0xFFFEE2E2),
    onErrorContainer:     Color(0xFF991B1B),
    background:           Color(0xFFF4F6F9),
    onBackground:         Color(0xFF1A1A2E),
    surface:              Colors.white,
    onSurface:            Color(0xFF1A1A2E),
    surfaceVariant:       Color(0xFFF3F4F6),
    onSurfaceVariant:     Color(0xFF6B7280),
    outline:              Color(0xFFE5E7EB),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1A1A2E),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'SFProText',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A2E),
    ),
    iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
    surfaceTintColor: Colors.transparent,
  ),

  textTheme: const TextTheme(
    bodyLarge:  TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1A1A2E)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF374151)),
    bodySmall:  TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF6B7280)),
    titleMedium:TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
    titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBrand, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kError)),
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kBrand,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontFamily: 'SFProText', fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kBrand)),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFF0F0F0)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: kBrand,
    unselectedItemColor: Color(0xFF9CA3AF),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 11),
  ),

  dividerTheme: const DividerThemeData(color: Color(0xFFF0F0F0), thickness: 1, space: 0),

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
