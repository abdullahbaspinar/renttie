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
import 'package:renttie/model/tenant.dart';
import 'package:renttie/view/home/widgets/app_header.dart';
import 'package:renttie/view/home/widgets/empty_state.dart';

class TenantsTab extends StatelessWidget {
  const TenantsTab({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        return Column(
          children: [
            AppHeader(user: user, title: 'Kiracılar'),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RentalState state) {
    if (state.tenants.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Henüz kiracı yok',
        subtitle: 'Kiracılarınızı mülklerinize bağlayarak ekleyin.',
        actionLabel: 'Kiracı Ekle',
        onAction: () => context.push(AppRoutes.addTenant),
      );
    }

    return ListView.builder(
      padding: AppSpacing.section,
      itemCount: state.tenants.length,
      itemBuilder: (context, index) {
        final tenant = state.tenants[index];
        final property = state.propertyById(tenant.propertyId);
        return _TenantCard(
          tenant: tenant,
          propertyName: property?.name ?? '-',
          onTap: () => context.push(
            AppRoutes.tenantDetailPath(tenant.id),
            extra: tenant,
          ),
          onDelete: () => _confirmDelete(context, tenant),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Tenant tenant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kiracıyı Sil'),
        content: Text('${tenant.name} silinsin mi?'),
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
      await context.read<RentalCubit>().deleteTenant(tenant.id);
    }
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({
    required this.tenant,
    required this.propertyName,
    required this.onTap,
    required this.onDelete,
  });

  final Tenant tenant;
  final String propertyName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        tenant.photoPath != null && File(tenant.photoPath!).existsSync();

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
            _buildAvatar(hasPhoto),
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

  Widget _buildAvatar(bool hasPhoto) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
      backgroundImage: hasPhoto ? FileImage(File(tenant.photoPath!)) : null,
      child: hasPhoto
          ? null
          : Text(
              tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tenant.name,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: AppTypography.sizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          propertyName,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: AppTypography.sizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (tenant.phone.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildContactRow(
            context,
            Icons.phone_outlined,
            tenant.phone,
          ),
        ],
        if (tenant.email.isNotEmpty) ...[
          const SizedBox(height: 2),
          _buildContactRow(
            context,
            Icons.email_outlined,
            tenant.email,
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ödeme: Her ayın ${tenant.paymentDay}. günü',
          style: AppTypography.caption(color: AppColors.textHint(context)),
        ),
      ],
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textHint(context)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall(color: AppColors.textSecondary(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
