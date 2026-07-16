import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/auth/auth_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/view/auth/widgets/auth_primary_button.dart';
import 'package:renttie/view/auth/widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    await context
        .read<AuthCubit>()
        .sendPasswordResetEmail(_emailController.text);
    if (!mounted) return;
    final state = context.read<AuthCubit>().state;
    if (state.status != AuthStatus.failure) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.pageHorizontal,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.xxxl),
                    if (_emailSent)
                      _buildSuccessContent(context)
                    else
                      _buildFormContent(context),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şifremi Unuttum',
          style: AppTypography.display(color: AppColors.textPrimary(context)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _emailSent
              ? 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'
              : 'Kayıtlı e-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
          style: AppTypography.bodyLarge(color: AppColors.textSecondary(context)),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.page,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _emailController.text.trim(),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AuthPrimaryButton(
          label: 'Giriş Sayfasına Dön',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: _emailController,
          label: 'E-posta',
          hint: 'ornek@email.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSendResetLink(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'E-posta adresi gerekli';
            }
            if (!value.contains('@')) return 'Geçerli bir e-posta girin';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xxxl),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return AuthPrimaryButton(
              label: 'Sıfırlama Bağlantısı Gönder',
              isLoading: state.status == AuthStatus.loading,
              onPressed: _handleSendResetLink,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Giriş sayfasına dön',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
