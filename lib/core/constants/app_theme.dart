import 'package:flutter/material.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_size.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';

/// Uygulama [ThemeData] tanımları.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.darkTextPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.darkTextPrimary,
          tertiary: AppColors.accent,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          onSurfaceVariant: AppColors.lightTextSecondary,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.lightBorder,
        ),
        textTheme: AppTypography.lightTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          toolbarHeight: AppSize.appBarHeight,
        ),
        dividerColor: AppColors.lightBorder,
        hintColor: AppColors.lightTextHint,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.darkTextPrimary,
            minimumSize: const Size.fromHeight(AppSize.buttonHeightMd),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            textStyle: AppTypography.button(),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          contentPadding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlAll,
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          margin: AppSpacing.only(bottom: AppSpacing.md),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.darkTextPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.darkTextPrimary,
          tertiary: AppColors.accent,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.darkBorder,
        ),
        textTheme: AppTypography.darkTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          toolbarHeight: AppSize.appBarHeight,
        ),
        dividerColor: AppColors.darkBorder,
        hintColor: AppColors.darkTextHint,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.darkTextPrimary,
            minimumSize: const Size.fromHeight(AppSize.buttonHeightMd),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            textStyle: AppTypography.button(),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlAll,
            side: const BorderSide(color: AppColors.darkBorder),
          ),
          margin: AppSpacing.only(bottom: AppSpacing.md),
        ),
      );
}
