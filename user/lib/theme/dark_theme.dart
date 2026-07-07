import 'package:flutter/material.dart';
import 'light_theme.dart'; // re-use brand constants

ThemeData darkTheme() => ThemeData(
  fontFamily: 'SFProText',
  useMaterial3: false,
  brightness: Brightness.dark,

  primaryColor: kBrand,
  primaryColorDark: kBrandDark,
  scaffoldBackgroundColor: const Color(0xFF0D1117),
  canvasColor: const Color(0xFF0D1117),
  cardColor: const Color(0xFF1C2333),
  dividerColor: const Color(0xFF2D3748),
  hintColor: const Color(0xFF6B7280),
  disabledColor: const Color(0xFF4B5563),
  shadowColor: Colors.black.withOpacity(0.3),
  dialogBackgroundColor: const Color(0xFF1C2333),

  colorScheme: const ColorScheme.dark(
    primary:              kBrand,
    onPrimary:            Colors.white,
    primaryContainer:     Color(0xFF0E3D38),
    onPrimaryContainer:   kBrandLight,
    secondary:            Color(0xFF7CB9E8),
    onSecondary:          Color(0xFF0D1117),
    secondaryContainer:   Color(0xFF1E3A5F),
    onSecondaryContainer: Color(0xFFBFD9F2),
    tertiary:             kSuccess,
    onTertiary:           Colors.white,
    tertiaryContainer:    Color(0xFF064E3B),
    onTertiaryContainer:  Color(0xFFA7F3D0),
    error:                kError,
    onError:              Colors.white,
    errorContainer:       Color(0xFF7F1D1D),
    onErrorContainer:     Color(0xFFFECACA),
    background:           Color(0xFF0D1117),
    onBackground:         Color(0xFFF9FAFB),
    surface:              Color(0xFF1C2333),
    onSurface:            Color(0xFFF9FAFB),
    surfaceVariant:       Color(0xFF243447),
    onSurfaceVariant:     Color(0xFF9CA3AF),
    outline:              Color(0xFF2D3748),
    shadow:               Color(0x40000000),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF161B27),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'SFProText',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    surfaceTintColor: Colors.transparent,
  ),

  textTheme: const TextTheme(
    displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFF9FAFB)),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFF9FAFB)),
    displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFF9FAFB)),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFF9FAFB)),
    headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFF9FAFB)),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFF9FAFB)),
    titleLarge:    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFFF9FAFB)),
    titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFF9FAFB)),
    titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFD1D5DB)),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFF9FAFB)),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFD1D5DB)),
    bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF)),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
    labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF243447),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2D3748)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2D3748)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kBrand, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError),
    ),
    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
    labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kBrand,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontFamily: 'SFProText',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: kBrand),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kBrand,
      side: const BorderSide(color: kBrand),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size(double.infinity, 52),
    ),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1C2333),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF2D3748)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF161B27),
    selectedItemColor: kBrand,
    unselectedItemColor: Color(0xFF6B7280),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 11),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF2D3748),
    thickness: 1,
    space: 0,
  ),

  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minVerticalPadding: 8,
  ),

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
