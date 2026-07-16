import 'package:flutter/material.dart';
import 'package:renttie/core/constants/app_colors.dart';

/// Tipografi ölçeği ve hazır [TextStyle] token'ları.
abstract final class AppTypography {
  static const String? fontFamily = null;

  static const double sizeXs = 11;
  static const double sizeSm = 12;
  static const double sizeMd = 13;
  static const double sizeBase = 14;
  static const double sizeLg = 16;
  static const double sizeXl = 18;
  static const double sizeXxl = 22;
  static const double sizeDisplay = 28;
  static const double sizeHero = 32;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static TextStyle display({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeHero,
        fontWeight: bold,
        height: 1.2,
        color: color,
      );

  static TextStyle headline({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeXxl,
        fontWeight: bold,
        height: 1.25,
        color: color,
      );

  static TextStyle title({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeXl,
        fontWeight: semiBold,
        height: 1.3,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeLg,
        fontWeight: semiBold,
        height: 1.35,
        color: color,
      );

  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeBase,
        fontWeight: regular,
        height: 1.45,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeLg,
        fontWeight: regular,
        height: 1.45,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeSm,
        fontWeight: regular,
        height: 1.4,
        color: color,
      );

  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeMd,
        fontWeight: medium,
        height: 1.3,
        color: color,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeXs,
        fontWeight: medium,
        height: 1.3,
        color: color,
      );

  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeLg,
        fontWeight: semiBold,
        height: 1.2,
        color: color,
      );

  static TextTheme lightTextTheme() => TextTheme(
        displayLarge: display(color: AppColors.lightTextPrimary),
        headlineMedium: headline(color: AppColors.lightTextPrimary),
        titleLarge: title(color: AppColors.lightTextPrimary),
        titleMedium: titleSmall(color: AppColors.lightTextPrimary),
        bodyLarge: bodyLarge(color: AppColors.lightTextPrimary),
        bodyMedium: body(color: AppColors.lightTextSecondary),
        bodySmall: bodySmall(color: AppColors.lightTextHint),
        labelLarge: button(color: AppColors.lightTextPrimary),
        labelMedium: label(color: AppColors.lightTextSecondary),
        labelSmall: caption(color: AppColors.lightTextHint),
      );

  static TextTheme darkTextTheme() => TextTheme(
        displayLarge: display(color: AppColors.darkTextPrimary),
        headlineMedium: headline(color: AppColors.darkTextPrimary),
        titleLarge: title(color: AppColors.darkTextPrimary),
        titleMedium: titleSmall(color: AppColors.darkTextPrimary),
        bodyLarge: bodyLarge(color: AppColors.darkTextPrimary),
        bodyMedium: body(color: AppColors.darkTextSecondary),
        bodySmall: bodySmall(color: AppColors.darkTextHint),
        labelLarge: button(color: AppColors.darkTextPrimary),
        labelMedium: label(color: AppColors.darkTextSecondary),
        labelSmall: caption(color: AppColors.darkTextHint),
      );
}
