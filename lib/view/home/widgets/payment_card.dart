import 'package:flutter/material.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/model/payment.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.showMessageAction = false,
    this.onMessageTap,
    this.onTap,
    this.isProrated = false,
  });

  final String title;
  final String dueDate;
  final int amount;
  final PaymentStatus status;
  final bool showMessageAction;
  final VoidCallback? onMessageTap;
  final VoidCallback? onTap;
  final bool isProrated;

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.xlAll,
              child: Padding(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: AppTypography.sizeLg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textHint(context),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Vade: $dueDate',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: AppTypography.sizeMd,
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
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        formatCurrency(amount),
                        style: TextStyle(
                          color: status == PaymentStatus.overdue
                              ? AppColors.error
                              : AppColors.secondary,
                          fontSize: AppTypography.sizeXl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColors.background,
                          borderRadius: AppRadius.xxlAll,
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: TextStyle(
                            color: statusColors.foreground,
                            fontSize: AppTypography.sizeSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
          ),
          if (showMessageAction)
            GestureDetector(
              onTap: onMessageTap,
              child: Container(
                width: 88,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: AppRadius.lgAll,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, color: Colors.white, size: 22),
                    SizedBox(height: 6),
                    Text(
                      'Mesaj\nİşaretle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _statusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.waiting:
        return 'Bekliyor';
      case PaymentStatus.overdue:
        return 'Gecikti';
      case PaymentStatus.paid:
        return 'Ödendi';
    }
  }

  ({Color background, Color foreground}) _statusColors(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.waiting:
        return (
          background: AppColors.warning.withValues(alpha: 0.18),
          foreground: const Color(0xFFB8860B),
        );
      case PaymentStatus.overdue:
        return (
          background: AppColors.error.withValues(alpha: 0.12),
          foreground: AppColors.error,
        );
      case PaymentStatus.paid:
        return (
          background: AppColors.success.withValues(alpha: 0.15),
          foreground: AppColors.success,
        );
    }
  }
}
