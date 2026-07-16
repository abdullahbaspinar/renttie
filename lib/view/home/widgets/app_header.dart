import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_routes.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.user,
    this.showBackButton = false,
    this.title,
  });

  final User? user;
  final bool showBackButton;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final initials = context.read<AuthCubit>().userInitials(user);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.of(context).padding.top + AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.pill),
          bottomRight: Radius.circular(AppRadius.pill),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.darkTextPrimary,
              ),
            ),
            Text(
              title ?? '',
              style: AppTypography.headline(color: AppColors.darkTextPrimary),
            ),
          ] else ...[
            Image.asset('assets/logo.png', width: 36, height: 36),
            const SizedBox(width: 10),
            Text(
              title ?? 'Renttie',
              style: AppTypography.headline(color: AppColors.darkTextPrimary),
            ),
          ],
          const Spacer(),
          _buildNotificationButton(context),
          _buildAvatar(context, initials),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.darkTextPrimary,
          ),
        ),
        const Positioned(
          right: 12,
          top: 12,
          child: CircleAvatar(
            radius: 4,
            backgroundColor: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String initials) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.profile),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.secondary,
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AppHeaderScaffold extends StatelessWidget {
  const AppHeaderScaffold({
    super.key,
    required this.user,
    required this.title,
    required this.child,
    this.showBackButton = true,
  });

  final User? user;
  final String title;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: Column(
          children: [
            AppHeader(
              user: user,
              showBackButton: showBackButton,
              title: title,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
