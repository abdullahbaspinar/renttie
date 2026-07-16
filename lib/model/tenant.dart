/// Kiranın ödenme zamanı:
/// - [advance]: peşin, dönem başında (önce öder sonra kalır).
/// - [arrears]: dönem sonunda (kalır sonra öder).
enum PaymentTiming { advance, arrears }

class Tenant {
  const Tenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.propertyId,
    required this.paymentDay,
    required this.depositAmount,
    required this.monthlyRent,
    this.leaseStart,
    this.leaseEnd,
    this.contractPath,
    this.photoPath,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.prorateFirstMonth = false,
    this.paymentTiming = PaymentTiming.advance,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String propertyId;
  final int paymentDay;
  final int depositAmount;
  final int monthlyRent;
  final DateTime? leaseStart;
  final DateTime? leaseEnd;
  final String? contractPath;
  final String? photoPath;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  /// İlk ay için giriş tarihi ile ödeme günü arasını kıst (gün bazlı) hesapla.
  final bool prorateFirstMonth;

  /// Kiranın peşin mi yoksa dönem sonunda mı ödeneceği.
  final PaymentTiming paymentTiming;

  String get paymentTimingLabel =>
      paymentTiming == PaymentTiming.advance ? 'Peşin (dönem başı)' : 'Dönem sonu';

  Tenant copyWith({
    String? name,
    String? phone,
    String? email,
    String? propertyId,
    int? paymentDay,
    int? depositAmount,
    int? monthlyRent,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    String? contractPath,
    String? photoPath,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? prorateFirstMonth,
    PaymentTiming? paymentTiming,
  }) {
    return Tenant(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      propertyId: propertyId ?? this.propertyId,
      paymentDay: paymentDay ?? this.paymentDay,
      depositAmount: depositAmount ?? this.depositAmount,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      contractPath: contractPath ?? this.contractPath,
      photoPath: photoPath ?? this.photoPath,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      prorateFirstMonth: prorateFirstMonth ?? this.prorateFirstMonth,
      paymentTiming: paymentTiming ?? this.paymentTiming,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'propertyId': propertyId,
        'paymentDay': paymentDay,
        'depositAmount': depositAmount,
        'monthlyRent': monthlyRent,
        'leaseStart': leaseStart?.toIso8601String(),
        'leaseEnd': leaseEnd?.toIso8601String(),
        'contractPath': contractPath,
        'photoPath': photoPath,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'prorateFirstMonth': prorateFirstMonth,
        'paymentTiming': paymentTiming.name,
      };

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        propertyId: json['propertyId'] as String,
        paymentDay: json['paymentDay'] as int? ?? 1,
        depositAmount: json['depositAmount'] as int? ?? 0,
        monthlyRent: json['monthlyRent'] as int? ?? 0,
        leaseStart: json['leaseStart'] != null
            ? DateTime.parse(json['leaseStart'] as String)
            : null,
        leaseEnd: json['leaseEnd'] != null
            ? DateTime.parse(json['leaseEnd'] as String)
            : null,
        contractPath: json['contractPath'] as String?,
        photoPath: json['photoPath'] as String?,
        emergencyContactName: json['emergencyContactName'] as String?,
        emergencyContactPhone: json['emergencyContactPhone'] as String?,
        prorateFirstMonth: json['prorateFirstMonth'] as bool? ?? false,
        paymentTiming: json['paymentTiming'] != null
            ? PaymentTiming.values.byName(json['paymentTiming'] as String)
            : PaymentTiming.advance,
      );
}
