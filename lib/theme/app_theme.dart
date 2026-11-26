import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF2EFE8);
  static const Color surface = Color(0xFFFAF7F0);
  static const Color surfaceVariant = Color(0xFFE7E2D8);

  static const Color primary = Color(0xFF1F4E3D);
  static const Color primaryContainer = Color(0xFFE3EFE6);

  static const Color accent = Color(0xFFC85A32);
  static const Color saffron = Color(0xFFE09F3E);

  static const Color textPrimary = Color(0xFF1D2420);
  static const Color textSecondary = Color(0xFF63766C);
  static const Color border = Color(0xFFDCD6C8);
  static const Color error = Color(0xFFBA3B3B);

  static const List<Color> rouletteSlices = [
    primary,
    accent,
    saffron,
    Color(0xFF3A7D65),
    Color(0xFFD97B48),
    Color(0xFF8C9E7E),
  ];
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        tertiary: AppColors.saffron,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outlineVariant: AppColors.border,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
