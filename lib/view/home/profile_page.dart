import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/auth/auth_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_routes.dart';
import 'package:renttie/view/home/widgets/app_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await context.read<AuthCubit>().signOut();
    // Auth başarılıysa GoRouter redirect authChoice'a alır.
  }

  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adınızı Güncelleyin'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Ad Soyad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !context.mounted) return;
    await context.read<AuthCubit>().updateDisplayName(newName);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adınız güncellendi')),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım & Destek'),
        content: const Text(
          'Soru ve önerileriniz için bize ulaşın:\n\ndestek@renttie.app',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final name = user?.displayName ?? 'Kullanıcı';
        final email = user?.email ?? '-';
        final initials = context.read<AuthCubit>().userInitials(user);

        return AppHeaderScaffold(
          user: user,
          title: 'Profil',
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              _buildProfileHeader(context, name, email, initials),
              const SizedBox(height: AppSpacing.xxxl),
              _ProfileTile(
                icon: Icons.person_outline,
                title: 'Hesap Bilgileri',
                subtitle: 'Adınızı güncelleyin',
                onTap: () => _editName(context, name == 'Kullanıcı' ? '' : name),
              ),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                title: 'Bildirimler',
                subtitle: 'Hatırlatıcı ve uyarılar',
                onTap: () => context.push(AppRoutes.notifications),
              ),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Yardım & Destek',
                subtitle: 'SSS ve iletişim',
                onTap: () => _showHelp(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildLogoutButton(context),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  'Renttie v1.0.0',
                  style: AppTypography.bodySmall(
                    color: AppColors.textHint(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    String initials,
  ) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.secondary,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            name,
            style: AppTypography.headline(color: AppColors.textPrimary(context)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            email,
            style: AppTypography.body(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _logout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillAll,
          ),
        ),
        child: const Text(
          'Çıkış Yap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface(context),
        borderRadius: AppRadius.lgAll,
        child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall(color: AppColors.textSecondary(context)),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textHint(context)),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: AppColors.border(context)),
        ),
      ),
      ),
    );
  }
}
