import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Geçersiz e-posta adresi.';
    case 'user-disabled':
      return 'Bu hesap devre dışı bırakılmış.';
    case 'user-not-found':
      return 'Bu e-posta ile kayıtlı hesap bulunamadı.';
    case 'wrong-password':
      return 'Hatalı şifre girdiniz.';
    case 'email-already-in-use':
      return 'Bu e-posta adresi zaten kullanılıyor.';
    case 'weak-password':
      return 'Şifre çok zayıf. En az 6 karakter kullanın.';
    case 'operation-not-allowed':
      return 'Bu giriş yöntemi etkin değil.';
    case 'too-many-requests':
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    case 'network-request-failed':
      return 'İnternet bağlantınızı kontrol edin.';
    case 'invalid-credential':
      return 'E-posta veya şifre hatalı.';
    default:
      return e.message ?? 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
