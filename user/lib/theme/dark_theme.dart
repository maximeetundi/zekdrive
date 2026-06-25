import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData darkTheme({Color primary = AppConstants.darkPrimary}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: primary,
  primaryColorDark: const Color(0xff9e2b00),
  disabledColor: const Color(0xFFBABFC4),
  scaffoldBackgroundColor: const Color(0xFF1C1F1F),
  canvasColor: const Color(0xFF1C1F1F),
  shadowColor: Colors.white.withOpacity(0.03),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: const Color(0xFF242424),
  textTheme:  const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Color(0xffd5e1e0)),
      bodyLarge: TextStyle(color: Color(0xffffffff)),
    titleMedium: TextStyle(color: Color(0xff1D2D2B)),
  ),
  colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF9100),
      error: Color(0xFFFF6767),
      background: Color(0xFFF3F3F3),
      secondary: Color(0xFFFF7A00),
      tertiary: Color(0xFF7CCD8B),
      tertiaryContainer: Color(0xFFC98B3E),
      secondaryContainer: Color(0xFFEE6464),
      onTertiary: Color(0xFFD9D9D9),
      onSecondary: Color(0xFFFFE0B2),
      onSecondaryContainer: Color(0xFFFFCC80),
      onTertiaryContainer: Color(0xFF425956),
      outline: Color(0xFFFFCC80),
      onPrimaryContainer: Color(0xFFFFF3E0),
      primaryContainer: Color(0xFFFFA800),
      onSurface: Color(0xFFFFE6AD),
      onPrimary: Color(0xFFFF7A00)


  ),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primary)),
);
