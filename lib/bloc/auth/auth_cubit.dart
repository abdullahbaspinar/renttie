import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:renttie/bloc/auth/auth_state.dart';
import 'package:renttie/services/auth_error_messages.dart';
import 'package:renttie/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthService? authService})
      : _authService = authService ?? AuthService.instance,
        super(const AuthState()) {
    _subscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  void _onAuthChanged(User? user) {
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      ));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _authService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: authErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Giriş başarısız oldu.',
      ));
    }
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: authErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Kayıt başarısız oldu.',
      ));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _authService.sendPasswordResetEmail(email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: authErrorMessage(e),
      ));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: authErrorMessage(e),
      ));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Google ile giriş başarısız oldu.',
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Google ile giriş başarısız oldu.',
      ));
    }
  }

  Future<void> updateDisplayName(String name) async {
    await _authService.updateDisplayName(name);
    emit(state.copyWith(user: _authService.currentUser));
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  String userInitials(User? user) => _authService.userInitials(user);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
