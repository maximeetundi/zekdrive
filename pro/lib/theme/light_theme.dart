import 'package:flutter/material.dart';
ThemeData lightTheme = ThemeData(
  fontFamily: 'SFProText',
  primaryColor: const Color(0xFFFF7A00),
  disabledColor: const Color(0xFFBABFC4),
  primaryColorDark: const Color(0xffE65100),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  colorScheme: const ColorScheme.light(
      primary: Color(0xFFFFCC80),
      background: Color(0xFFF3F3F3),
      error: Color(0xFFFF6767),
      secondary: Color(0xFFFF7A00),
    tertiary: Color(0xFF7CCD8B),
    tertiaryContainer: Color(0xFFC98B3E),
    secondaryContainer: Color(0xFFEE6464),
    onTertiary: Color(0xFFD9D9D9),
    onSecondary: Color(0xFFFFB74D),
    onSecondaryContainer: Color(0xFFFFCC80),
    onTertiaryContainer: Color(0xFF425956),
    outline: Color(0xFFFFCC80),
    onPrimaryContainer: Color(0xFFFFF3E0),
    primaryContainer: Color(0xFFFFA800),
    onErrorContainer: Color(0xFFFFE6AD),
    onPrimary: Color(0xFFFF7A00),
    surfaceTint: Color(0xFFE65100),
    errorContainer: Color(0xFFF6F6F6),
    shadow: Color(0xFFFFE0B2)


  ),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7A00))),

  textTheme: const TextTheme(
   displayLarge: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF202020)),
   displayMedium: TextStyle(fontWeight: FontWeight.w300, color: Color(
       0xFF393939)),
   displaySmall: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF282828)),
   bodyLarge: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF272727)),
    bodyMedium: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF334257)),
    bodySmall: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF1D2D2B)),

  )
);
