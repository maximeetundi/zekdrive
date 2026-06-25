import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData lightTheme({Color color = AppConstants.lightPrimary}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  primaryColorDark: const Color(0xFFE65100),
  disabledColor: const Color(0xFFBABFC4),
  dialogBackgroundColor: const Color(0xFFEEEEEE),
  scaffoldBackgroundColor: const Color(0xFFFF7A00),
  shadowColor: Colors.black.withOpacity(0.03),
  textTheme:  const TextTheme(
    bodyMedium: TextStyle(color: Color(0xff1D2D2B)),
    bodySmall: TextStyle(color: Color(0xff6B7675)),
    bodyLarge: TextStyle(color: Color(0xff48615E)),
    titleMedium: TextStyle(color: Color(0xff1D2D2B)),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),

  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF7A00),
      //  secondary: Color(0xFFFF7A00),
      error: Color(0xFFFF6767),
      background: Color(0xFFF3F3F3),
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
  ),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
);
