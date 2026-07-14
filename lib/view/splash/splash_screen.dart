import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renttie/constants/app_colors.dart';
import 'package:renttie/view/auth_choice/auth_choice.dart';
import 'package:renttie/view/splash/on_boarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunchAndNavigate();
  }

  Future<void> _checkFirstLaunchAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isFirstLaunch ? const OnboardingPage() : const AuthChoicePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildRenttieLogoAndText(context),
              const Spacer(),
              _buildFooterText(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRenttieLogoAndText(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo.png',
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 20),
        Text(
          'Renttie',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kiranız Güvende.',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return Text(
      'Sürüm 1.0.0 | Powered by Renttie',
      style: TextStyle(
        color: AppColors.textHint(context),
        fontSize: 12,
      ),
    );
  }
}
