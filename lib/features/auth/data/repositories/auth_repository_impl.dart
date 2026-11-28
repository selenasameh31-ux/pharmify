import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// تنفيذ عقد تسجيل الدخول: بيمرر النداءات لمصدر البيانات المختار
/// (Firebase أو محلي).
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _ds;
  const AuthRepositoryImpl(this._ds);

  @override
  Future<AppUser?> restoreSession() => _ds.restoreSession();
  @override
  Future<AppUser> signIn(String email, String password) =>
      _ds.signIn(email, password);
  @override
  Future<AppUser> signUp(String name, String email, String password) =>
      _ds.signUp(name, email, password);
  @override
  Future<void> signOut() => _ds.signOut();
  @override
  Future<void> sendPasswordReset(String email) => _ds.sendPasswordReset(email);
  @override
  Future<AppUser> signInWithGoogle() => _ds.signInWithGoogle();
}
