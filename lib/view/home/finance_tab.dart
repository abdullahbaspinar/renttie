import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/view/home/widgets/app_header.dart';
import 'package:renttie/view/home/widgets/empty_state.dart';

class FinanceTab extends StatelessWidget {
  const FinanceTab({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        return Column(
          children: [
            AppHeader(user: user, title: 'Finans'),
            _buildStats(context, state),
            const SizedBox(height: AppSpacing.lg),
            _buildPeriodFilters(context, state),
            const SizedBox(height: AppSpacing.sm),
            _buildFilters(context, state),
            Expanded(child: _buildPaymentsList(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildPeriodFilters(BuildContext context, RentalState state) {
    Widget chip(String label, FinancePeriod period) {
      return _FilterChip(
        label: label,
        selected: state.financePeriod == period,
        onTap: () => context.read<RentalCubit>().setFinancePeriod(period),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          chip('Tümü', FinancePeriod.all),
          chip('Geçmiş', FinancePeriod.past),
          chip('Bu Ay', FinancePeriod.current),
          chip('Gelecek', FinancePeriod.future),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, RentalState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _FinanceStatCard(
              label: 'Bu Ay Alınan',
              amount: state.homeSummary.received,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _FinanceStatCard(
              label: 'Geciken',
              amount: state.homeSummary.overdue,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, RentalState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tümü',
            selected: state.financeFilter == null,
            onTap: () => context.read<RentalCubit>().setFinanceFilter(null),
          ),
          _FilterChip(
            label: 'Bekliyor',
            selected: state.financeFilter == PaymentStatus.waiting,
            onTap: () => context
                .read<RentalCubit>()
                .setFinanceFilter(PaymentStatus.waiting),
          ),
          _FilterChip(
            label: 'Gecikti',
            selected: state.financeFilter == PaymentStatus.overdue,
            onTap: () => context
                .read<RentalCubit>()
                .setFinanceFilter(PaymentStatus.overdue),
          ),
          _FilterChip(
            label: 'Ödendi',
            selected: state.financeFilter == PaymentStatus.paid,
            onTap: () => context
                .read<RentalCubit>()
                .setFinanceFilter(PaymentStatus.paid),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, RentalState state) {
    final months = state.financePaymentsByMonth;
    if (months.isEmpty) {
      return const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Ödeme kaydı yok',
        subtitle: 'Ödeme ekleyerek finans takibine başlayın.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final entry = months[index];
        return _MonthSection(month: entry.key, payments: entry.value);
      },
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({required this.month, required this.payments});

  final DateTime month;
  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    final total = payments.fold(0, (sum, p) => sum + p.amount);
    final paid = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold(0, (sum, p) => sum + p.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              Text(
                formatMonthYear(month),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: AppTypography.sizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${formatCurrency(paid)} / ${formatCurrency(total)}',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: AppTypography.sizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...payments.map((payment) {
          final state = context.read<RentalCubit>().state;
          final property = state.propertyById(payment.propertyId);
          final tenant = state.tenantById(payment.tenantId);
          return _FinancePaymentTile(
            title: '${property?.name ?? ''} - ${tenant?.name ?? ''}',
            date: formatShortDate(payment.dueDate),
            amount: payment.amount,
            status: payment.status,
            isProrated: payment.isProrated,
            onMarkPaid: payment.status != PaymentStatus.paid
                ? () => context.read<RentalCubit>().markPaymentPaid(payment.id)
                : null,
          );
        }),
      ],
    );
  }
}

class _FinanceStatCard extends StatelessWidget {
  const _FinanceStatCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

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
          Text(
            label,
            style: AppTypography.label(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: AppTypography.sizeXl,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.secondary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.secondary,
      ),
    );
  }
}

class _FinancePaymentTile extends StatelessWidget {
  const _FinancePaymentTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    this.isProrated = false,
    this.onMarkPaid,
  });

  final String title;
  final String date;
  final int amount;
  final PaymentStatus status;
  final bool isProrated;
  final VoidCallback? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      PaymentStatus.waiting => AppColors.warning,
      PaymentStatus.overdue => AppColors.error,
      PaymentStatus.paid => AppColors.success,
    };

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
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: AppTypography.bodySmall(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    if (isProrated) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Kıst',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(amount),
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                switch (status) {
                  PaymentStatus.waiting => 'Bekliyor',
                  PaymentStatus.overdue => 'Gecikti',
                  PaymentStatus.paid => 'Ödendi',
                },
                style: TextStyle(
                  color: statusColor,
                  fontSize: AppTypography.sizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (onMarkPaid != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onMarkPaid,
              icon: const Icon(Icons.check_circle_outline),
              color: AppColors.success,
              tooltip: 'Ödendi olarak işaretle',
            ),
          ],
        ],
      ),
    );
  }
}
