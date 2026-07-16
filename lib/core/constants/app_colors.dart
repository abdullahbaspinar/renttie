import 'package:flutter/material.dart';

/// Uygulama renk paleti ve tema-duyarlı yardımcıları.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF0F2C42);
  static const Color secondary = Color(0xFF107C53);
  static const Color accent = Color(0xFF1ABC9C);

  // Semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF1C40F);
  static const Color error = Color(0xFFE74C3C);

  // Light
  static const Color lightBackground = Color(0xFFF4F7F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1C2833);
  static const Color lightTextSecondary = Color(0xFF566573);
  static const Color lightTextHint = Color(0xFFABB2B9);
  static const Color lightBorder = Color(0xFFE5E8E8);

  // Dark
  static const Color darkBackground = Color(0xFF0A1926);
  static const Color darkSurface = Color(0xFF122538);
  static const Color darkTextPrimary = Color(0xFFF2F4F4);
  static const Color darkTextSecondary = Color(0xFFBDC3C7);
  static const Color darkTextHint = Color(0xFF7F8C8D);
  static const Color darkBorder = Color(0xFF1B3249);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color textHint(BuildContext context) =>
      isDark(context) ? darkTextHint : lightTextHint;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;
}
