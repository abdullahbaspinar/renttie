import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/auth/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/router/app_routes.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    await context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        // Auth başarılıysa GoRouter redirect home'a alır.
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Stack(
          children: [
            _buildBackgroundLayer(context),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(context),
                  const Spacer(),
                  _buildIllustration(),
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: AppColors.border(context)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 48, height: 48),
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
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kiranızı Kolayca Yönetin',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 180,
      child: Image.asset('assets/auth_choice/auth.png', fit: BoxFit.contain),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final loading = state.status == AuthStatus.loading;
              return ElevatedButton(
                onPressed: loading ? null : () => _handleGoogleSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface(context),
                  foregroundColor: AppColors.textPrimary(context),
                  side: BorderSide(color: AppColors.border(context)),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
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
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.push(AppRoutes.login);
            },
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
            onPressed: () {
              context.push(AppRoutes.register);
            },
            child: Text(
              'Hesap Oluştur',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final color = AppColors.textPrimary(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('TR', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('|', style: TextStyle(color: color.withValues(alpha: 0.4))),
        ),
        Text('EN', style: TextStyle(color: color.withValues(alpha: 0.5))),
      ],
    );
  }
}
