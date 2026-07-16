import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_routes.dart';

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxxl)),
      ),
      builder: (context) => const QuickAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: AppRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Hızlı Ekle',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Portföyünüze yeni kayıt ekleyin',
              style: AppTypography.body(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: AppSpacing.xl),
            _QuickAddTile(
              icon: Icons.apartment_outlined,
              label: 'Mülk Ekle',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.addProperty);
              },
            ),
            _QuickAddTile(
              icon: Icons.person_add_outlined,
              label: 'Kiracı Ekle',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.addTenant);
              },
            ),
            _QuickAddTile(
              icon: Icons.payments_outlined,
              label: 'Ödeme Ekle',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.addPayment);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.lgAll,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textHint(context)),
      ),
    );
  }
}
