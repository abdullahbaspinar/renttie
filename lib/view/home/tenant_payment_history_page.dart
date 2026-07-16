import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/payment_stats.dart';
import 'package:renttie/model/tenant.dart';

class TenantPaymentHistoryPage extends StatelessWidget {
  const TenantPaymentHistoryPage({super.key, required this.tenant});

  final Tenant tenant;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        final payments = state.payments
            .where((p) => p.tenantId == tenant.id)
            .toList()
          ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
        final paidPayments =
            payments.where((p) => p.paidDate != null).toList();
        final stats = PaymentStats.fromPayments(payments);

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            foregroundColor: AppColors.textPrimary(context),
            title: const Text('Ödeme Geçmişi'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                tenant.name,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStatsCards(context, stats),
              const SizedBox(height: AppSpacing.md),
              _buildBehaviorBanner(context, stats),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Yapılan Ödemeler',
                style: AppTypography.title(color: AppColors.textPrimary(context)),
              ),
              const SizedBox(height: 10),
              if (paidPayments.isEmpty)
                Text(
                  'Bu kiracının tamamlanmış ödemesi yok.',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                )
              else
                ...paidPayments.map(
                  (p) => _PaidPaymentTile(payment: p),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(BuildContext context, PaymentStats stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Zamanında Ödeme',
            value: stats.hasData
                ? '%${stats.onTimePercentage.round()}'
                : '-',
            color: AppColors.success,
            icon: Icons.verified_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            label: 'Yapılan Ödeme',
            value: '${stats.paidCount}',
            color: AppColors.accent,
            icon: Icons.receipt_long_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorBanner(BuildContext context, PaymentStats stats) {
    final rounded = stats.averageDaysLate.round();
    final (color, icon) = !stats.hasData
        ? (AppColors.textSecondary(context), Icons.info_outline)
        : rounded > 0
            ? (AppColors.error, Icons.trending_down)
            : rounded < 0
                ? (AppColors.success, Icons.trending_up)
                : (AppColors.success, Icons.check_circle_outline);

    return Container(
      padding: AppSpacing.page,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ödeme Alışkanlığı',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  stats.behaviorLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.page,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}

class _PaidPaymentTile extends StatelessWidget {
  const _PaidPaymentTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final daysLate = payment.daysLate ?? 0;
    final (latenessLabel, latenessColor) = daysLate > 0
        ? ('$daysLate gün geç', AppColors.error)
        : daysLate < 0
            ? ('${-daysLate} gün erken', AppColors.success)
            : ('Zamanında', AppColors.success);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatFullDate(payment.dueDate),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.paidDate != null
                      ? 'Ödendi: ${formatFullDate(payment.paidDate!)}'
                      : '',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(payment.amount),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: latenessColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  latenessLabel,
                  style: TextStyle(
                    color: latenessColor,
                    fontSize: AppTypography.sizeXs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
