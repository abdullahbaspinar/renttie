enum PaymentStatus { waiting, overdue, paid }

class Payment {
  const Payment({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.messageMarked = false,
    this.isProrated = false,
  });

  final String id;
  final String propertyId;
  final String tenantId;
  final int amount;
  final DateTime dueDate;
  final PaymentStatus status;
  final DateTime? paidDate;
  final bool messageMarked;

  /// Kıst (gün bazlı) hesaplanmış ilk ödeme mi.
  final bool isProrated;

  String get statusLabel {
    switch (status) {
      case PaymentStatus.waiting:
        return 'Bekliyor';
      case PaymentStatus.overdue:
        return 'Gecikti';
      case PaymentStatus.paid:
        return 'Ödendi';
    }
  }

  /// Ödemenin vadesine göre kaç gün geç/erken yapıldığı.
  /// Pozitif = geç, negatif = erken, 0 = tam zamanında. Ödenmediyse null.
  int? get daysLate {
    if (paidDate == null) return null;
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final paid = DateTime(paidDate!.year, paidDate!.month, paidDate!.day);
    return paid.difference(due).inDays;
  }

  Payment copyWith({
    PaymentStatus? status,
    DateTime? paidDate,
    bool clearPaidDate = false,
    bool? messageMarked,
    bool? isProrated,
  }) {
    return Payment(
      id: id,
      propertyId: propertyId,
      tenantId: tenantId,
      amount: amount,
      dueDate: dueDate,
      status: status ?? this.status,
      paidDate: clearPaidDate ? null : (paidDate ?? this.paidDate),
      messageMarked: messageMarked ?? this.messageMarked,
      isProrated: isProrated ?? this.isProrated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'propertyId': propertyId,
        'tenantId': tenantId,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'status': status.name,
        'paidDate': paidDate?.toIso8601String(),
        'messageMarked': messageMarked,
        'isProrated': isProrated,
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        propertyId: json['propertyId'] as String,
        tenantId: json['tenantId'] as String,
        amount: json['amount'] as int,
        dueDate: DateTime.parse(json['dueDate'] as String),
        status: PaymentStatus.values.byName(json['status'] as String),
        paidDate: json['paidDate'] != null
            ? DateTime.parse(json['paidDate'] as String)
            : null,
        messageMarked: json['messageMarked'] as bool? ?? false,
        isProrated: json['isProrated'] as bool? ?? false,
      );
}

String formatCurrency(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final position = text.length - i;
    buffer.write(text[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${buffer.toString()} TL';
}

const _turkishMonths = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

String formatMonthYear(DateTime date) =>
    '${_turkishMonths[date.month - 1]} ${date.year}';

String formatShortDate(DateTime date) =>
    '${date.day} ${_turkishMonths[date.month - 1].substring(0, 3)}';

String formatFullDate(DateTime date) =>
    '${date.day} ${_turkishMonths[date.month - 1]} ${date.year}';

String currentMonthLabel() {
  final now = DateTime.now();
  return '${_turkishMonths[now.month - 1]} Özeti';
}
