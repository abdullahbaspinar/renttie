import 'package:equatable/equatable.dart';
import 'package:renttie/model/home_data.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/property.dart';
import 'package:renttie/model/tenant.dart';

enum RentalStatus { initial, loading, loaded, failure }

enum FinancePeriod { all, past, current, future }

class RentalState extends Equatable {
  const RentalState({
    this.status = RentalStatus.initial,
    this.properties = const [],
    this.tenants = const [],
    this.payments = const [],
    this.financeFilter,
    this.financePeriod = FinancePeriod.all,
    this.errorMessage,
  });

  final RentalStatus status;
  final List<Property> properties;
  final List<Tenant> tenants;
  final List<Payment> payments;
  final PaymentStatus? financeFilter;
  final FinancePeriod financePeriod;
  final String? errorMessage;

  HomeSummary get homeSummary {
    final now = DateTime.now();
    final monthPayments = payments.where((p) {
      return p.dueDate.year == now.year && p.dueDate.month == now.month;
    }).toList();

    final totalExpected =
        monthPayments.fold(0, (sum, p) => sum + p.amount);
    final received = monthPayments
        .where((p) => p.status == PaymentStatus.paid)
        .fold(0, (sum, p) => sum + p.amount);
    final overdue = monthPayments
        .where((p) => p.status == PaymentStatus.overdue)
        .fold(0, (sum, p) => sum + p.amount);

    return HomeSummary(
      monthLabel: currentMonthLabel(),
      totalExpected: totalExpected,
      received: received,
      overdue: overdue,
    );
  }

  List<Payment> get upcomingPayments {
    final now = DateTime.now();
    final horizon = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 60));
    final active = payments
        .where((p) =>
            p.status != PaymentStatus.paid && p.dueDate.isBefore(horizon))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return active;
  }

  bool _matchesPeriod(Payment p, DateTime now) {
    final currentMonth = DateTime(now.year, now.month);
    final dueMonth = DateTime(p.dueDate.year, p.dueDate.month);
    switch (financePeriod) {
      case FinancePeriod.all:
        return true;
      case FinancePeriod.past:
        return dueMonth.isBefore(currentMonth);
      case FinancePeriod.current:
        return dueMonth.isAtSameMomentAs(currentMonth);
      case FinancePeriod.future:
        return dueMonth.isAfter(currentMonth);
    }
  }

  /// Döneme ve duruma göre filtrelenmiş, ilk ödemeden son ödemeye (artan)
  /// sıralı ödemeler.
  List<Payment> get filteredFinancePayments {
    final now = DateTime.now();
    return payments
        .where((p) => _matchesPeriod(p, now))
        .where((p) => financeFilter == null || p.status == financeFilter)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Filtrelenmiş ödemeleri aya göre (artan) gruplar.
  List<MapEntry<DateTime, List<Payment>>> get financePaymentsByMonth {
    final grouped = <DateTime, List<Payment>>{};
    for (final p in filteredFinancePayments) {
      final key = DateTime(p.dueDate.year, p.dueDate.month);
      grouped.putIfAbsent(key, () => []).add(p);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Property? propertyById(String id) {
    try {
      return properties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Tenant? tenantById(String id) {
    try {
      return tenants.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Tenant? tenantForProperty(String propertyId) {
    try {
      return tenants.firstWhere((t) => t.propertyId == propertyId);
    } catch (_) {
      return null;
    }
  }

  RentalState copyWith({
    RentalStatus? status,
    List<Property>? properties,
    List<Tenant>? tenants,
    List<Payment>? payments,
    PaymentStatus? financeFilter,
    bool clearFinanceFilter = false,
    FinancePeriod? financePeriod,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RentalState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      tenants: tenants ?? this.tenants,
      payments: payments ?? this.payments,
      financeFilter:
          clearFinanceFilter ? null : (financeFilter ?? this.financeFilter),
      financePeriod: financePeriod ?? this.financePeriod,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        properties,
        tenants,
        payments,
        financeFilter,
        financePeriod,
        errorMessage,
      ];
}
