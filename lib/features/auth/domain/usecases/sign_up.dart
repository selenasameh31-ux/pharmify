import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام: إنشاء حساب جديد.
class SignUp {
  final AuthRepository _repo;
  const SignUp(this._repo);
  Future<AppUser> call(String name, String email, String password) =>
      _repo.signUp(name, email, password);
}
