import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/model/payment.dart';

class PaymentDetailSheet extends StatelessWidget {
  const PaymentDetailSheet({super.key, required this.paymentId});

  final String paymentId;

  static Future<void> show(BuildContext context, String paymentId) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxxl)),
      ),
      builder: (context) => PaymentDetailSheet(paymentId: paymentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        final payment =
            state.payments.where((p) => p.id == paymentId).firstOrNull;
        if (payment == null) {
          return const SizedBox(height: 120);
        }
        final property = state.propertyById(payment.propertyId);
        final tenant = state.tenantById(payment.tenantId);
        final isPaid = payment.status == PaymentStatus.paid;

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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Ödeme Detayı',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _DetailRow(
                  label: 'Mülk',
                  value: property?.name ?? '-',
                ),
                _DetailRow(
                  label: 'Kiracı',
                  value: tenant?.name ?? '-',
                ),
                _DetailRow(
                  label: 'Tutar',
                  value: formatCurrency(payment.amount),
                  valueColor: AppColors.secondary,
                ),
                if (payment.isProrated)
                  const _DetailRow(
                    label: 'Ödeme tipi',
                    value: 'Kıst kira (gün bazlı)',
                    valueColor: AppColors.accent,
                  ),
                _DetailRow(
                  label: 'Vade tarihi',
                  value: formatFullDate(payment.dueDate),
                ),
                _DetailRow(
                  label: 'Durum',
                  value: payment.statusLabel,
                  valueColor: _statusColor(payment.status),
                ),
                if (payment.paidDate != null)
                  _DetailRow(
                    label: 'Ödenme tarihi',
                    value: formatFullDate(payment.paidDate!),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                _buildActionButton(context, payment, isPaid),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      BuildContext context, Payment payment, bool isPaid) {
    if (isPaid) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () async {
            await context.read<RentalCubit>().markPaymentUnpaid(payment.id);
            if (context.mounted) Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.pillAll,
            ),
          ),
          icon: const Icon(Icons.undo),
          label: const Text(
            'Ödenmedi olarak işaretle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () async {
          await context.read<RentalCubit>().markPaymentPaid(payment.id);
          if (context.mounted) Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillAll,
          ),
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'Ödendi olarak işaretle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.waiting:
        return AppColors.warning;
      case PaymentStatus.overdue:
        return AppColors.error;
      case PaymentStatus.paid:
        return AppColors.success;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
