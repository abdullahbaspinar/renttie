import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/property.dart';
import 'package:renttie/model/tenant.dart';
import 'package:renttie/services/rental_data_service.dart';

class RentalCubit extends Cubit<RentalState> {
  RentalCubit({RentalDataService? dataService})
      : _dataService = dataService ?? RentalDataService.instance,
        super(const RentalState());

  final RentalDataService _dataService;
  StreamSubscription<void>? _dataChangesSub;

  Future<void> loadForUser(String? userId) async {
    emit(state.copyWith(status: RentalStatus.loading, clearError: true));
    try {
      await _dataService.loadForUser(userId);
      _dataChangesSub?.cancel();
      _dataChangesSub = _dataService.changes.listen((_) => _emitLoaded());
      _emitLoaded();
    } catch (e) {
      emit(state.copyWith(
        status: RentalStatus.failure,
        errorMessage: 'Veriler yüklenemedi.',
      ));
    }
  }

  List<Payment> _applyOverdueStatuses(List<Payment> payments) {
    final today = _todayDate();
    return payments.map((p) {
      if (p.status == PaymentStatus.waiting && p.dueDate.isBefore(today)) {
        return p.copyWith(status: PaymentStatus.overdue);
      }
      return p;
    }).toList();
  }

  void _emitLoaded() {
    emit(state.copyWith(
      status: RentalStatus.loaded,
      properties: List.unmodifiable(_dataService.properties),
      tenants: List.unmodifiable(_dataService.tenants),
      payments:
          List.unmodifiable(_applyOverdueStatuses(_dataService.payments)),
      clearError: true,
    ));
  }

  String newId(String prefix) => _dataService.newId(prefix);

  static DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  PaymentStatus _statusForDue(DateTime due, DateTime today) =>
      due.isBefore(today) ? PaymentStatus.overdue : PaymentStatus.waiting;

  /// Kira dönemi boyunca her ay, ödeme gününe denk gelen ödemeleri üretir.
  /// Kıst kira açıksa ve giriş günü ödeme gününden farklıysa, giriş tarihi ile
  /// ilk normal ödeme günü arasını gün bazlı hesaplayan bir kıst ödeme ekler.
  List<Payment> _generatePaymentsForTenant(Tenant tenant) {
    final start = tenant.leaseStart;
    final end = tenant.leaseEnd;
    if (start == null || end == null || tenant.monthlyRent <= 0) return [];

    final today = _todayDate();
    final startDate = DateTime(start.year, start.month, start.day);
    final advance = tenant.paymentTiming == PaymentTiming.advance;
    final payments = <Payment>[];
    final baseId = DateTime.now().millisecondsSinceEpoch;

    // İlk normal ödeme gününü bul (giriş tarihine eşit veya sonrası).
    DateTime firstRegular;
    if (start.day <= tenant.paymentDay) {
      firstRegular = DateTime(start.year, start.month, tenant.paymentDay);
    } else {
      firstRegular = DateTime(start.year, start.month + 1, tenant.paymentDay);
    }

    // Kıst (gün bazlı) ilk ödeme.
    // Peşin: kısmi dönemin başında (giriş günü) ödenir.
    // Dönem sonu: kısmi dönemin sonunda (ilk ödeme günü) ödenir.
    if (tenant.prorateFirstMonth && start.day != tenant.paymentDay) {
      final days = firstRegular.difference(startDate).inDays;
      if (days > 0) {
        final proratedAmount = (tenant.monthlyRent * days / 30).round();
        final due = advance ? startDate : firstRegular;
        payments.add(Payment(
          id: 'pay_${baseId}_prorated',
          propertyId: tenant.propertyId,
          tenantId: tenant.id,
          amount: proratedAmount,
          dueDate: due,
          status: _statusForDue(due, today),
          isProrated: true,
        ));
      }
    }

    var year = firstRegular.year;
    var month = firstRegular.month;

    // Sonsuz döngüye karşı 10 yıl (120 ay) üst sınırı.
    // Peşin: ödeme dönem başında (ödeme günü) yapılır.
    // Dönem sonu: ödeme dönem sonunda (bir sonraki ödeme günü) yapılır.
    for (var i = 0; i < 120; i++) {
      final periodStart = DateTime(year, month, tenant.paymentDay);
      if (periodStart.isAfter(end)) break;
      final due = advance
          ? periodStart
          : DateTime(year, month + 1, tenant.paymentDay);
      payments.add(Payment(
        id: 'pay_${baseId}_$i',
        propertyId: tenant.propertyId,
        tenantId: tenant.id,
        amount: tenant.monthlyRent,
        dueDate: due,
        status: _statusForDue(due, today),
      ));
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    return payments;
  }

  Future<void> addProperty(Property property) async {
    _dataService.properties = [..._dataService.properties, property];
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> updateProperty(Property property) async {
    _dataService.properties = _dataService.properties
        .map((p) => p.id == property.id ? property : p)
        .toList();
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> addTenant(Tenant tenant) async {
    _dataService.tenants = [..._dataService.tenants, tenant];
    _dataService.payments = [
      ..._dataService.payments,
      ..._generatePaymentsForTenant(tenant),
    ];
    await _dataService.save();
    _emitLoaded();
  }

  /// Kiracıyı günceller; ödenmiş ödemeleri korur, kalan ödemeleri kira
  /// dönemine göre yeniden üretir.
  Future<void> updateTenant(Tenant tenant) async {
    _dataService.tenants = _dataService.tenants
        .map((t) => t.id == tenant.id ? tenant : t)
        .toList();

    final paid = _dataService.payments
        .where((p) => p.tenantId == tenant.id && p.status == PaymentStatus.paid)
        .toList();
    final others = _dataService.payments
        .where((p) => p.tenantId != tenant.id)
        .toList();
    final regenerated = _generatePaymentsForTenant(tenant).where((generated) {
      return !paid.any((p) =>
          p.dueDate.year == generated.dueDate.year &&
          p.dueDate.month == generated.dueDate.month);
    }).toList();

    _dataService.payments = [...others, ...paid, ...regenerated];
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> addPayment(Payment payment) async {
    _dataService.payments = [..._dataService.payments, payment];
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> markPaymentPaid(String paymentId, {DateTime? paidDate}) async {
    final index =
        _dataService.payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) return;
    final updated = List<Payment>.from(_dataService.payments);
    updated[index] = updated[index].copyWith(
      status: PaymentStatus.paid,
      paidDate: paidDate ?? DateTime.now(),
    );
    _dataService.payments = updated;
    await _dataService.save();
    _emitLoaded();
  }

  /// Ödemeyi geri alır; vadesine göre "Bekliyor" veya "Gecikti" olur.
  Future<void> markPaymentUnpaid(String paymentId) async {
    final index =
        _dataService.payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) return;
    final updated = List<Payment>.from(_dataService.payments);
    final payment = updated[index];
    final status = payment.dueDate.isBefore(_todayDate())
        ? PaymentStatus.overdue
        : PaymentStatus.waiting;
    updated[index] = payment.copyWith(
      status: status,
      clearPaidDate: true,
    );
    _dataService.payments = updated;
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> markPaymentMessage(String paymentId) async {
    final index =
        _dataService.payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) return;
    final updated = List<Payment>.from(_dataService.payments);
    updated[index] = updated[index].copyWith(messageMarked: true);
    _dataService.payments = updated;
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> deleteProperty(String id) async {
    _dataService.properties =
        _dataService.properties.where((p) => p.id != id).toList();
    _dataService.tenants =
        _dataService.tenants.where((t) => t.propertyId != id).toList();
    _dataService.payments =
        _dataService.payments.where((p) => p.propertyId != id).toList();
    await _dataService.save();
    _emitLoaded();
  }

  Future<void> deleteTenant(String id) async {
    _dataService.tenants =
        _dataService.tenants.where((t) => t.id != id).toList();
    _dataService.payments =
        _dataService.payments.where((p) => p.tenantId != id).toList();
    await _dataService.save();
    _emitLoaded();
  }

  void setFinanceFilter(PaymentStatus? filter) {
    emit(state.copyWith(
      financeFilter: filter,
      clearFinanceFilter: filter == null,
    ));
  }

  void setFinancePeriod(FinancePeriod period) {
    emit(state.copyWith(financePeriod: period));
  }

  @override
  Future<void> close() {
    _dataChangesSub?.cancel();
    return super.close();
  }
}
