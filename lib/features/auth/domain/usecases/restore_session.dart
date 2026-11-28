import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// حالة استخدام: استرجاع الجلسة المحفوظة لو المستخدم مسجل دخوله.
class RestoreSession {
  final AuthRepository _repo;
  const RestoreSession(this._repo);
  Future<AppUser?> call() => _repo.restoreSession();
}
