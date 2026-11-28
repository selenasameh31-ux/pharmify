import '../repositories/auth_repository.dart';

/// حالة استخدام: تسجيل الخروج.
class SignOut {
  final AuthRepository _repo;
  const SignOut(this._repo);
  Future<void> call() => _repo.signOut();
}
