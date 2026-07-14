import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renttie/constants/app_colors.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            _buildBackgroundLayer(context),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  _buildHeaderLogoAndText(context),
                  const Spacer(),
                  _buildIllustrationSpace,
                  const Spacer(),
                  _buildAuthButtons(context),
                  const SizedBox(height: 24),
                  _buildLanguageSelector(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: screenSize.height * 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          border: Border.all(color: AppColors.border(context), width: 1),
        ),
      ),
    );
  }

  Widget _buildHeaderLogoAndText(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 48,
              height: 48,
            ),
            const SizedBox(width: 12),
            Text(
              'Renttie',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Hoş Geldiniz',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kiranızı Kolayca Yönetin',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget get _buildIllustrationSpace {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 180,
      child: Center(
        child: Image.asset(
          'assets/auth_choice/auth.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.isDark(context)
                  ? AppColors.darkBackground
                  : AppColors.lightSurface,
              foregroundColor: AppColors.textPrimary(context),
              elevation: 1,
              side: BorderSide(color: AppColors.border(context)),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logos/google_logo.png',
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  'Google ile Giriş Yap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.darkTextPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'E-posta ile Giriş',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text(
              'Hesap Oluştur',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final textColor = AppColors.textPrimary(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TR',
          style: TextStyle(
            color: textColor.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '|',
            style: TextStyle(color: textColor.withValues(alpha: 0.4)),
          ),
        ),
        Text(
          'EN',
          style: TextStyle(
            color: textColor.withValues(alpha: 0.5),
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
