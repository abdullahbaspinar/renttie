import 'dart:async';

import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/auth/auth_state.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';

/// Router seviyesinde yan etkiler (ör. giriş sonrası veri yükleme).
///
/// Navigasyon [GoRouter] redirect ile yönetilir; bu sınıf yalnızca
/// auth durumuna bağlı iş kurallarını çalıştırır.
class AppRouterEffects {
  AppRouterEffects({
    required this.authCubit,
    required this.rentalCubit,
  });

  final AuthCubit authCubit;
  final RentalCubit rentalCubit;
  StreamSubscription<AuthState>? _subscription;
  String? _loadedUserId;

  void start() {
    _subscription?.cancel();
    _subscription = authCubit.stream.listen(_onAuthState);
    _onAuthState(authCubit.state);
  }

  void _onAuthState(AuthState state) {
    if (state.isAuthenticated) {
      final uid = state.user!.uid;
      if (_loadedUserId == uid) return;
      _loadedUserId = uid;
      unawaited(rentalCubit.loadForUser(uid));
      return;
    }

    if (state.status == AuthStatus.unauthenticated) {
      _loadedUserId = null;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
