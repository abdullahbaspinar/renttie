import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/property.dart';
import 'package:renttie/model/tenant.dart';

class RentalDataService {
  RentalDataService._();

  static final RentalDataService instance = RentalDataService._();

  static const _rootCollection = 'users';

  List<Property> properties = [];
  List<Tenant> tenants = [];
  List<Payment> payments = [];
  String? _userId;

  StreamController<void>? _changesController;

  Stream<void> get changes =>
      _changesController?.stream ?? const Stream.empty();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _propertiesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tenantsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _paymentsSub;

  Future<void> loadForUser(String? userId) async {
    _userId = userId ?? 'guest';

    _cancelSubs();
    _changesController ??= StreamController<void>.broadcast();

    await _loadOnceAndSeedIfNeeded();
    _startListeners();
  }

  void _cancelSubs() {
    _propertiesSub?.cancel();
    _tenantsSub?.cancel();
    _paymentsSub?.cancel();
    _propertiesSub = null;
    _tenantsSub = null;
    _paymentsSub = null;
  }

  CollectionReference<Map<String, dynamic>> _propsCollection() {
    if (_userId == null) {
      throw StateError('loadForUser() çağrılmadan kullanılamaz.');
    }
    return FirebaseFirestore.instance
        .collection(_rootCollection)
        .doc(_userId)
        .collection('properties');
  }

  CollectionReference<Map<String, dynamic>> _tenantsCollection() {
    if (_userId == null) {
      throw StateError('loadForUser() çağrılmadan kullanılamaz.');
    }
    return FirebaseFirestore.instance
        .collection(_rootCollection)
        .doc(_userId)
        .collection('tenants');
  }

  CollectionReference<Map<String, dynamic>> _paymentsCollection() {
    if (_userId == null) {
      throw StateError('loadForUser() çağrılmadan kullanılamaz.');
    }
    return FirebaseFirestore.instance
        .collection(_rootCollection)
        .doc(_userId)
        .collection('payments');
  }

  Future<void> _loadOnceAndSeedIfNeeded() async {
    QuerySnapshot<Map<String, dynamic>> propsSnap;
    QuerySnapshot<Map<String, dynamic>> tenantsSnap;
    QuerySnapshot<Map<String, dynamic>> paymentsSnap;
    try {
      propsSnap = await _propsCollection().get();
      tenantsSnap = await _tenantsCollection().get();
      paymentsSnap = await _paymentsCollection().get();
    } on MissingPluginException catch (e) {
      throw StateError(
        'Firestore eklentisi yüklenmedi. Uygulamayı tamamen yeniden derleyin. ($e)',
      );
    } on PlatformException catch (e) {
      throw StateError(
        'Firestore bağlantısı kurulamadı. Tam yeniden derleme gerekli olabilir: ${e.message ?? e.code}',
      );
    }

    final hasAny = propsSnap.docs.isNotEmpty ||
        tenantsSnap.docs.isNotEmpty ||
        paymentsSnap.docs.isNotEmpty;

    if (!hasAny) {
      _seedDemoData();
      await save();
      // save sonrası tekrar çek
      return _loadOnceAndSeedIfNeeded();
    }

    properties = propsSnap.docs
        .map((d) => Property.fromJson(d.data()))
        .toList();
    tenants = tenantsSnap.docs
        .map((d) => Tenant.fromJson(d.data()))
        .toList();
    payments = paymentsSnap.docs
        .map((d) => Payment.fromJson(d.data()))
        .toList();
  }

  void _startListeners() {
    _propertiesSub = _propsCollection().snapshots().listen((snap) {
      properties = snap.docs
          .map((d) => Property.fromJson(d.data()))
          .toList();
      _notify();
    });

    _tenantsSub = _tenantsCollection().snapshots().listen((snap) {
      tenants = snap.docs
          .map((d) => Tenant.fromJson(d.data()))
          .toList();
      _notify();
    });

    _paymentsSub = _paymentsCollection().snapshots().listen((snap) {
      payments = snap.docs
          .map((d) => Payment.fromJson(d.data()))
          .toList();
      _notify();
    });
  }

  void _notify() {
    if (_changesController == null || _changesController!.isClosed) return;
    _changesController!.add(null);
  }

  void _seedDemoData() {
    final now = DateTime.now();

    final property1 = Property(
      id: 'prop_1',
      name: 'Daire 3A',
      address: 'Kadıköy, İstanbul',
      type: PropertyType.apartment,
    );
    final property2 = Property(
      id: 'prop_2',
      name: 'Ofis B',
      address: 'Levent, İstanbul',
      type: PropertyType.office,
    );

    final tenant1 = Tenant(
      id: 'tenant_1',
      name: 'Ayşe Yılmaz',
      phone: '0532 111 22 33',
      email: 'ayse@email.com',
      propertyId: property1.id,
      paymentDay: 15,
      depositAmount: 12000,
      monthlyRent: 12000,
      leaseStart: DateTime(now.year, now.month - 2, 15),
      leaseEnd: DateTime(now.year + 1, now.month - 2, 14),
    );
    final tenant2 = Tenant(
      id: 'tenant_2',
      name: 'Can Polat',
      phone: '0544 555 66 77',
      email: 'can@email.com',
      propertyId: property2.id,
      paymentDay: 10,
      depositAmount: 25000,
      monthlyRent: 25000,
      leaseStart: DateTime(now.year, now.month - 1, 10),
      leaseEnd: DateTime(now.year + 1, now.month - 1, 9),
    );
    properties = [property1, property2];
    tenants = [tenant1, tenant2];
    payments = [
      Payment(
        id: 'pay_1',
        propertyId: property1.id,
        tenantId: tenant1.id,
        amount: 12000,
        dueDate: DateTime(now.year, now.month, 15),
        status: PaymentStatus.waiting,
      ),
      Payment(
        id: 'pay_2',
        propertyId: property1.id,
        tenantId: tenant1.id,
        amount: 12000,
        dueDate: DateTime(now.year, now.month - 1, 15),
        status: PaymentStatus.paid,
        paidDate: DateTime(now.year, now.month - 1, 17),
      ),
      Payment(
        id: 'pay_3',
        propertyId: property1.id,
        tenantId: tenant1.id,
        amount: 12000,
        dueDate: DateTime(now.year, now.month - 2, 15),
        status: PaymentStatus.paid,
        paidDate: DateTime(now.year, now.month - 2, 15),
      ),
      Payment(
        id: 'pay_4',
        propertyId: property2.id,
        tenantId: tenant2.id,
        amount: 25000,
        dueDate: DateTime(now.year, now.month, 10),
        status: PaymentStatus.overdue,
      ),
      Payment(
        id: 'pay_5',
        propertyId: property2.id,
        tenantId: tenant2.id,
        amount: 25000,
        dueDate: DateTime(now.year, now.month - 1, 10),
        status: PaymentStatus.paid,
        paidDate: DateTime(now.year, now.month - 1, 15),
      ),
    ];
  }

  Future<void> _syncCollection<T>({
    required CollectionReference<Map<String, dynamic>> colRef,
    required String Function(T item) idOf,
    required Map<String, dynamic> Function(T item) toJsonOf,
    required List<T> current,
  }) async {
    QuerySnapshot<Map<String, dynamic>> existingSnap;
    try {
      existingSnap = await colRef.get();
    } on MissingPluginException catch (e) {
      throw StateError(
        'Firestore eklentisi yüklenmedi. Uygulamayı tamamen yeniden derleyin. ($e)',
      );
    } on PlatformException catch (e) {
      throw StateError(
        'Firestore bağlantısı kurulamadı. Tam yeniden derleme gerekli olabilir: ${e.message ?? e.code}',
      );
    }
    final existingIds = existingSnap.docs.map((d) => d.id).toSet();
    final currentIds = current.map(idOf).toSet();

    final batch = FirebaseFirestore.instance.batch();

    for (final item in current) {
      batch.set(colRef.doc(idOf(item)), toJsonOf(item));
    }

    for (final id in existingIds.difference(currentIds)) {
      batch.delete(colRef.doc(id));
    }

    try {
      await batch.commit();
    } on MissingPluginException catch (e) {
      throw StateError(
        'Firestore eklentisi yüklenmedi. Uygulamayı tamamen yeniden derleyin. ($e)',
      );
    } on PlatformException catch (e) {
      throw StateError(
        'Firestore yazma işlemi başarısız: ${e.message ?? e.code}',
      );
    }
  }

  Future<void> save() async {
    if (_userId == null) return;
    await _syncCollection<Property>(
      colRef: _propsCollection(),
      current: properties,
      idOf: (p) => p.id,
      toJsonOf: (p) => p.toJson(),
    );
    await _syncCollection<Tenant>(
      colRef: _tenantsCollection(),
      current: tenants,
      idOf: (t) => t.id,
      toJsonOf: (t) => t.toJson(),
    );
    await _syncCollection<Payment>(
      colRef: _paymentsCollection(),
      current: payments,
      idOf: (p) => p.id,
      toJsonOf: (p) => p.toJson(),
    );
  }

  String newId(String prefix) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
}
