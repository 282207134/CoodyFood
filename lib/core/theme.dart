import 'package:flutter/material.dart';

abstract final class CoodyColors {
  static const primary = Color(0xFFEF3800);
  static const ink = Color(0xFF091E42);
  static const muted = Color(0xFF7A869A);
  static const background = Color(0xFFF4F5F7);
  static const peach = Color(0xFFFFEBE5);
  static const green = Color(0xFF00875A);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'DM Sans',
  scaffoldBackgroundColor: CoodyColors.background,
  colorScheme: ColorScheme.fromSeed(seedColor: CoodyColors.primary).copyWith(
    primary: CoodyColors.primary,
    surface: Colors.white,
    onSurface: CoodyColors.ink,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: CoodyColors.ink,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: CoodyColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: CoodyColors.ink,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: CoodyColors.ink, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, color: CoodyColors.ink, height: 1.45),
    bodySmall: TextStyle(fontSize: 12, color: CoodyColors.muted, height: 1.5),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: CoodyColors.ink,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: CoodyColors.ink,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: CoodyColors.background,
    thickness: 1,
    space: 24,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: CoodyColors.background,
    hintStyle: const TextStyle(color: CoodyColors.muted, fontSize: 14),
    labelStyle: const TextStyle(color: CoodyColors.muted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: CoodyColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: CoodyColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 48),
      elevation: 0,
      textStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: CoodyColors.ink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
