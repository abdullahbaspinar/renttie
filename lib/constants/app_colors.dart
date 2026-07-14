import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF0F2C42); // Gece Mavisi (Midnight Blue)
  static const Color secondary = Color(0xFF107C53); // Zümrüt Yeşili (Emerald Green)
  static const Color accent = Color(0xFF1ABC9C); // Turkuaz / Enerji Rengi
  static const Color success = Color(0xFF2ECC71); // Ödendi / Aktif
  static const Color warning = Color(0xFFF1C40F); // Bekliyor / Yenileniyor
  static const Color error = Color(0xFFE74C3C); // Gecikti / İptal

  static const Color lightBackground = Color(0xFFF4F7F6); // Hafif Gri/Yeşilimsi Beyaz
  static const Color lightSurface = Color(0xFFFFFFFF); // Kartlar ve Saf Beyaz Alanlar
  static const Color lightTextPrimary = Color(0xFF1C2833); // Ana Başlıklar
  static const Color lightTextSecondary = Color(0xFF566573); // Alt Başlıklar / Açıklamalar
  static const Color lightTextHint = Color(0xFFABB2B9); // Input Hint / Pasif Elemanlar
  static const Color lightBorder = Color(0xFFE5E8E8); // İnce Çizgiler / Divider

  static const Color darkBackground = Color(0xFF0A1926); // Çok Koyu Gece Mavisi
  static const Color darkSurface = Color(0xFF122538); // Kartlar ve Yüzeyler
  static const Color darkTextPrimary = Color(0xFFF2F4F4); // Ana Başlıklar
  static const Color darkTextSecondary = Color(0xFFBDC3C7); // Alt Başlıklar / Gri Metinler
  static const Color darkTextHint = Color(0xFF7F8C8D); // Input Hint / Pasif Elemanlar
  static const Color darkBorder = Color(0xFF1B3249); // Koyu Tema İnce Çizgiler

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