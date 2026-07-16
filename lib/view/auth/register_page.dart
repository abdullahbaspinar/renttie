import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/auth/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_routes.dart';
import 'package:renttie/view/auth/widgets/auth_primary_button.dart';
import 'package:renttie/view/auth/widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devam etmek için kullanım koşullarını kabul edin'),
        ),
      );
      return;
    }

    await context.read<AuthCubit>().registerWithEmail(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.pageHorizontal,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.xxxl),
                    _buildNameField(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildEmailField(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildPasswordField(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildConfirmPasswordField(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTermsRow(context),
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildLoginLink(context),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap Oluştur',
          style: AppTypography.display(color: AppColors.textPrimary(context)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Renttie ile kira yönetimine hemen başlayın.',
          style: AppTypography.bodyLarge(color: AppColors.textSecondary(context)),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return AuthTextField(
      controller: _nameController,
      label: 'Ad Soyad',
      hint: 'Adınız Soyadınız',
      textInputAction: TextInputAction.next,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Ad soyad gerekli' : null,
    );
  }

  Widget _buildEmailField() {
    return AuthTextField(
      controller: _emailController,
      label: 'E-posta',
      hint: 'ornek@email.com',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-posta adresi gerekli';
        }
        if (!value.contains('@')) return 'Geçerli bir e-posta girin';
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return AuthTextField(
      controller: _passwordController,
      label: 'Şifre',
      hint: 'En az 6 karakter',
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textHint(context),
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Şifre gerekli';
        if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(BuildContext context) {
    return AuthTextField(
      controller: _confirmPasswordController,
      label: 'Şifre Tekrar',
      hint: 'Şifrenizi tekrar girin',
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleRegister(),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textHint(context),
        ),
        onPressed: () => setState(
          () => _obscureConfirmPassword = !_obscureConfirmPassword,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Şifre tekrarı gerekli';
        if (value != _passwordController.text) return 'Şifreler eşleşmiyor';
        return null;
      },
    );
  }

  Widget _buildTermsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            activeColor: AppColors.secondary,
            side: BorderSide(color: AppColors.border(context)),
            onChanged: (value) {
              setState(() => _acceptedTerms = value ?? false);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: Text(
              'Kullanım koşullarını ve gizlilik politikasını kabul ediyorum.',
              style: AppTypography.body(color: AppColors.textSecondary(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return AuthPrimaryButton(
          label: 'Hesap Oluştur',
          isLoading: state.status == AuthStatus.loading,
          onPressed: _handleRegister,
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabınız var mı?',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: Text(
            'Giriş Yap',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
