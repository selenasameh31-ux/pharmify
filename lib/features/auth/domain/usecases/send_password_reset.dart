import '../repositories/auth_repository.dart';

/// حالة استخدام: إرسال لينك إعادة تعيين الباسورد.
class SendPasswordReset {
  final AuthRepository _repo;
  const SendPasswordReset(this._repo);
  Future<void> call(String email) => _repo.sendPasswordReset(email);
}
