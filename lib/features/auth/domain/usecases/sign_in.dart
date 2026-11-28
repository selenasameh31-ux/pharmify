import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام: تسجيل الدخول بالإيميل والباسورد.
class SignIn {
  final AuthRepository _repo;
  const SignIn(this._repo);
  Future<AppUser> call(String email, String password) => _repo.signIn(email, password);
}
