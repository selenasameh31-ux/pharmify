import '../entities/app_user.dart';

/// عقد طبقة الدومين لتسجيل الدخول. التنفيذ في طبقة البيانات:
/// نسخة تجريبية على الجهاز ونسخة حقيقية على Firebase.
abstract class AuthRepository {
  Future<AppUser?> restoreSession();
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp(String name, String email, String password);
  Future<void> signOut();

  /// يبعت لينك إعادة تعيين الباسورد على الإيميل.
  Future<void> sendPasswordReset(String email);

  /// تسجيل الدخول بحساب جوجل.
  Future<AppUser> signInWithGoogle();
}
