import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GoRouter'ın auth / bootstrap değişimlerinde yeniden yönlendirme yapması için
/// [ChangeNotifier] tabanlı yenileme kaynağı.
class AppRouterRefresh extends ChangeNotifier {
  AppRouterRefresh(this._authCubit) {
    _authSub = _authCubit.stream.listen((_) => notifyListeners());
  }

  static const _firstLaunchKey = 'isFirstLaunch';

  final AuthCubit _authCubit;
  StreamSubscription<dynamic>? _authSub;

  bool _bootstrapped = false;
  bool _isFirstLaunch = true;

  bool get bootstrapped => _bootstrapped;
  bool get isFirstLaunch => _isFirstLaunch;

  /// Splash sırasında SharedPreferences + auth hazırlığını tamamlar.
  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    _bootstrapped = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
    _isFirstLaunch = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
