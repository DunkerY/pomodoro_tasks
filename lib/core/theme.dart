import 'package:flutter/material.dart';

class AppTheme {
  static const purple1 = Color(0xFF6C63FF);
  static const purple2 = Color(0xFF9C27B0);
  static const purpleLight = Color(0xFFEDE7FF);
  static const gray1 = Color(0xFF1E1E2E);
  static const gray2 = Color(0xFF2A2A3E);
  static const gray3 = Color(0xFF3A3A50);
  static const gray4 = Color(0xFF9E9EBA);
  static const white = Color(0xFFFFFFFF);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: gray1,
    colorScheme: ColorScheme.dark(
      primary: purple1,
      secondary: purple2,
      surface: gray2,
      onPrimary: white,
      onSurface: white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: gray2,
      indicatorColor: purple1.withValues(alpha: 0.1),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: purple1);
        }
        return const IconThemeData(color: gray4);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: purple1,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
        }
        return const TextStyle(color: gray4, fontSize: 12);
      }),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: gray1,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: white),
    ),
    cardTheme: CardThemeData(
      color: gray2,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: gray3,
      labelStyle: const TextStyle(color: white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gray4.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: purple1, width: 1.5),
      ),
      labelStyle: const TextStyle(color: gray4),
      hintStyle: const TextStyle(color: gray4),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: white),
      bodyMedium: TextStyle(color: white),
      bodySmall: TextStyle(color: gray4),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: purple1,
      foregroundColor: white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purple1,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
