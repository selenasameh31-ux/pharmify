import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام: تسجيل الدخول بحساب جوجل.
class SignInWithGoogle {
  final AuthRepository _repo;
  const SignInWithGoogle(this._repo);
  Future<AppUser> call() => _repo.signInWithGoogle();
}
