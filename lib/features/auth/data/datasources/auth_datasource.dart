import '../../domain/entities/app_user.dart';

/// عقد مصدر بيانات تسجيل الدخول: Firebase Auth أو محلي (الوضع التجريبي).
abstract class AuthDataSource {
  Future<AppUser?> restoreSession();
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp(String name, String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<AppUser> signInWithGoogle();
}
