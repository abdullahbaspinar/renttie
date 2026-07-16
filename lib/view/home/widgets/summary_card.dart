import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/model/home_data.dart';
import 'package:renttie/model/payment.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.section,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D5C3F),
            Color(0xFF107C53),
            Color(0xFF1ABC9C),
          ],
        ),
        borderRadius: AppRadius.xxxlAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.monthLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Beklenen Toplam',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrency(summary.totalExpected),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(
                  painter: _SummaryDonutPainter(
                    receivedRatio: summary.receivedRatio,
                    overdueRatio: summary.overdueRatio,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'Alınan',
                  amount: formatCurrency(summary.received),
                  indicatorColor: AppColors.accent,
                  progress: summary.receivedRatio,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _SummaryStat(
                  label: 'Geciken',
                  amount: formatCurrency(summary.overdue),
                  indicatorColor: AppColors.warning,
                  progress: summary.overdueRatio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.indicatorColor,
    required this.progress,
  });

  final String label;
  final String amount;
  final Color indicatorColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.xsAll,
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 4,
            backgroundColor: Colors.white24,
            color: indicatorColor,
          ),
        ),
      ],
    );
  }
}

class _SummaryDonutPainter extends CustomPainter {
  _SummaryDonutPainter({
    required this.receivedRatio,
    required this.overdueRatio,
  });

  final double receivedRatio;
  final double overdueRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const stroke = 10.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke);

    final background = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, background);

    final receivedPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final overduePaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    canvas.drawArc(
      rect,
      start,
      math.pi * 2 * receivedRatio,
      false,
      receivedPaint,
    );
    canvas.drawArc(
      rect,
      start + math.pi * 2 * receivedRatio,
      math.pi * 2 * overdueRatio,
      false,
      overduePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SummaryDonutPainter oldDelegate) {
    return oldDelegate.receivedRatio != receivedRatio ||
        oldDelegate.overdueRatio != overdueRatio;
  }
}
