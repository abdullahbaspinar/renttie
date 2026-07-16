import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_routes.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/property.dart';
import 'package:renttie/model/tenant.dart';
import 'package:renttie/view/home/widgets/app_header.dart';
import 'package:renttie/view/home/widgets/empty_state.dart';

class PropertiesTab extends StatelessWidget {
  const PropertiesTab({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        return Column(
          children: [
            AppHeader(user: user, title: 'Mülklerim'),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RentalState state) {
    if (state.properties.isEmpty) {
      return EmptyState(
        icon: Icons.apartment_outlined,
        title: 'Henüz mülk yok',
        subtitle: 'İlk mülkünüzü ekleyerek başlayın.',
        actionLabel: 'Mülk Ekle',
        onAction: () => context.push(AppRoutes.addProperty),
      );
    }

    return ListView.builder(
      padding: AppSpacing.section,
      itemCount: state.properties.length,
      itemBuilder: (context, index) {
        final property = state.properties[index];
        final tenant = state.tenantForProperty(property.id);
        return _PropertyCard(
          property: property,
          tenant: tenant,
          onTap: () => context.push(
            AppRoutes.propertyDetailPath(property.id),
            extra: property,
          ),
          onDelete: () => _confirmDelete(context, property),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mülkü Sil'),
        content: Text(
          '${property.name} silinsin mi? Bağlı kiracı ve ödemeler de silinir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<RentalCubit>().deleteProperty(property.id);
    }
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.tenant,
    required this.onTap,
    required this.onDelete,
  });

  final Property property;
  final Tenant? tenant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData get _icon => switch (property.type) {
        PropertyType.apartment => Icons.apartment_outlined,
        PropertyType.office => Icons.business_outlined,
        PropertyType.shop => Icons.storefront_outlined,
        PropertyType.other => Icons.home_work_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        property.photoPath != null && File(property.photoPath!).existsSync();

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xlAll,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: AppSpacing.page,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            _buildThumbnail(hasPhoto),
            const SizedBox(width: 14),
            Expanded(child: _buildInfo(context)),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool hasPhoto) {
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: Container(
        width: 60,
        height: 60,
        color: AppColors.secondary.withValues(alpha: 0.12),
        child: hasPhoto
            ? Image.file(File(property.photoPath!), fit: BoxFit.cover)
            : Icon(_icon, color: AppColors.secondary),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.name,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: AppTypography.sizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          property.address,
          style: AppTypography.label(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                property.typeLabel,
                style: AppTypography.caption(color: AppColors.accent),
              ),
            ),
            if (tenant != null && tenant!.monthlyRent > 0) ...[
              const SizedBox(width: 8),
              Text(
                formatCurrency(tenant!.monthlyRent),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: AppTypography.sizeMd,
                ),
              ),
            ],
          ],
        ),
        if (tenant != null) ...[
          const SizedBox(height: 6),
          Text(
            'Kiracı: ${tenant!.name}',
            style: AppTypography.bodySmall(color: AppColors.textSecondary(context)),
          ),
        ],
      ],
    );
  }
}
