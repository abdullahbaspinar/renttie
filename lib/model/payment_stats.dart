import 'package:renttie/model/payment.dart';

/// Bir kiracının ödeme geçmişinden hesaplanan performans özeti.
class PaymentStats {
  const PaymentStats({
    required this.paidCount,
    required this.totalPaidAmount,
    required this.onTimeCount,
    required this.averageDaysLate,
  });

  /// Ödenmiş ödeme adedi.
  final int paidCount;

  /// Ödenmiş ödemelerin toplam tutarı.
  final int totalPaidAmount;

  /// Vadesinde veya öncesinde ödenen ödeme adedi.
  final int onTimeCount;

  /// Ortalama gecikme (gün). Pozitif = geç, negatif = erken, 0 = zamanında.
  final double averageDaysLate;

  bool get hasData => paidCount > 0;

  /// Zamanında (veya erken) ödeme yüzdesi (0-100).
  double get onTimePercentage =>
      paidCount == 0 ? 0 : (onTimeCount / paidCount) * 100;

  /// Ödeme alışkanlığını özetleyen etiket.
  String get behaviorLabel {
    if (!hasData) return 'Henüz ödeme yok';
    final rounded = averageDaysLate.round();
    if (rounded == 0) return 'Tam zamanında ödüyor';
    if (rounded < 0) return 'Ortalama ${-rounded} gün erken ödüyor';
    return 'Ortalama $rounded gün geç ödüyor';
  }

  factory PaymentStats.fromPayments(List<Payment> payments) {
    final paid = payments.where((p) => p.paidDate != null).toList();
    if (paid.isEmpty) {
      return const PaymentStats(
        paidCount: 0,
        totalPaidAmount: 0,
        onTimeCount: 0,
        averageDaysLate: 0,
      );
    }

    final totalAmount = paid.fold(0, (sum, p) => sum + p.amount);
    final onTime = paid.where((p) => (p.daysLate ?? 0) <= 0).length;
    final totalDaysLate =
        paid.fold(0, (sum, p) => sum + (p.daysLate ?? 0));

    return PaymentStats(
      paidCount: paid.length,
      totalPaidAmount: totalAmount,
      onTimeCount: onTime,
      averageDaysLate: totalDaysLate / paid.length,
    );
  }
}
