import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/firebase_options.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../models/app_user_model.dart';
import 'auth_datasource.dart';

/// وضع تجريبي: تسجيل الدخول على الجهاز نفسه من غير إنترنت ولا Firebase.
/// بيشتغل لحد ما تحطي إعدادات Firebase في firebase_options.dart.
class LocalAuthDataSource implements AuthDataSource {
  LocalAuthDataSource(this._prefs);
  final SharedPreferences _prefs;

  static const _usersKey = 'demo_users_v1';
  static const _sessionKey = 'demo_session_v1';

  Map<String, dynamic> _users() {
    final raw = _prefs.getString(_usersKey);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  AppUser _toUser(Map<String, dynamic> m) => AppUserModel.fromJson(m);

  @override
  Future<AppUser?> restoreSession() async {
    final email = _prefs.getString(_sessionKey);
    if (email == null) return null;
    final u = _users()[email];
    return u == null ? null : _toUser(Map<String, dynamic>.from(u as Map));
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    final key = email.trim().toLowerCase();
    final u = _users()[key];
    if (u == null || (u as Map)['password'] != password) {
      throw AuthFailure(tr('الإيميل أو الباسورد غلط', 'Wrong email or password'));
    }
    await _prefs.setString(_sessionKey, key);
    return _toUser(Map<String, dynamic>.from(u));
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    final key = email.trim().toLowerCase();
    final users = _users();
    if (users.containsKey(key)) {
      throw AuthFailure(tr('الإيميل ده مسجل قبل كده', 'This email is already registered'));
    }
    final user = AppUserModel(
      uid: 'u${DateTime.now().microsecondsSinceEpoch}',
      email: key,
      name: name.trim(),
      role: kAdminEmails.map((e) => e.toLowerCase()).contains(key)
          ? UserRole.admin
          : UserRole.rep,
    );
    users[key] = {...user.toJson(), 'password': password};
    await _prefs.setString(_usersKey, jsonEncode(users));
    await _prefs.setString(_sessionKey, key);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    throw AuthFailure(tr('استرجاع الباسورد بيشتغل بعد ما تتوصل Firebase', 'Password reset works once Firebase is connected'));
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    throw AuthFailure(tr('تسجيل جوجل بيشتغل بعد ما تتوصل Firebase', 'Google sign-in works once Firebase is connected'));
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_sessionKey);
  }
}
