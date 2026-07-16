import 'dart:io';

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

class PropertyDetailPage extends StatelessWidget {
  const PropertyDetailPage({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        // Düzenleme sonrası güncel veriyi state'ten al.
        final current = state.propertyById(property.id) ?? property;
        final tenant = state.tenantForProperty(current.id);
        final payments = state.payments
            .where((p) => p.propertyId == current.id)
            .toList()
          ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
        final hasPhoto = current.photoPath != null &&
            File(current.photoPath!).existsSync();

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            foregroundColor: AppColors.textPrimary(context),
            title: const Text('Mülk Detayı'),
            actions: [
              IconButton(
                tooltip: 'Düzenle',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  AppRoutes.editPropertyPath(current.id),
                  extra: current,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: AppSpacing.only(
              left: AppSpacing.xl,
              top: AppSpacing.sm,
              right: AppSpacing.xl,
              bottom: AppSpacing.xxl,
            ),
            children: [
              _buildPhoto(context, current, hasPhoto),
              const SizedBox(height: AppSpacing.xl),
              _buildTitle(context, current),
              const SizedBox(height: AppSpacing.xl),
              _buildInfoCard(context, current, tenant),
              const SizedBox(height: AppSpacing.xxl),
              _buildPaymentsSection(context, payments),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoto(
      BuildContext context, Property property, bool hasPhoto) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.xxlAll,
        border: Border.all(color: AppColors.border(context)),
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(property.photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : const Icon(
              Icons.apartment_outlined,
              size: 72,
              color: AppColors.secondary,
            ),
    );
  }

  Widget _buildTitle(BuildContext context, Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.name,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          property.address,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context, Property property, Tenant? tenant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Mülk tipi',
            value: property.typeLabel,
          ),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Aylık kira',
            value: tenant != null && tenant.monthlyRent > 0
                ? formatCurrency(tenant.monthlyRent)
                : 'Kiracı atanınca belirlenir',
          ),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Kiracı',
            value: tenant?.name ?? 'Kiracı atanmadı',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection(BuildContext context, List<Payment> payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ödeme Geçmişi',
          style: AppTypography.title(color: AppColors.textPrimary(context)),
        ),
        const SizedBox(height: 10),
        if (payments.isEmpty)
          Text(
            'Bu mülke ait ödeme kaydı yok.',
            style: TextStyle(color: AppColors.textSecondary(context)),
          )
        else
          ...payments.map((payment) => _PaymentHistoryTile(payment: payment)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  const _PaymentHistoryTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (payment.status) {
      PaymentStatus.waiting => AppColors.warning,
      PaymentStatus.overdue => AppColors.error,
      PaymentStatus.paid => AppColors.success,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatShortDate(payment.dueDate),
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          Text(
            formatCurrency(payment.amount),
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            payment.statusLabel,
            style: TextStyle(
              color: statusColor,
              fontSize: AppTypography.sizeSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
