import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_refresh.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await context.read<AppRouterRefresh>().bootstrap();
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
            children: [
              const Spacer(),
              _buildLogoAndText(context),
              const Spacer(),
              _buildFooter(context),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndText(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/logo.png', width: 120, height: 120),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Renttie',
          style: AppTypography.display(
            color: AppColors.textPrimary(context),
          ).copyWith(fontSize: 40, letterSpacing: 1.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Kiranız Güvende.',
          style: AppTypography.bodyLarge(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text(
      'Sürüm 1.0.0 | Powered by Renttie',
      style: AppTypography.bodySmall(color: AppColors.textHint(context)),
    );
  }
}
