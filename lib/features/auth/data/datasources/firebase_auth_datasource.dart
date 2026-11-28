import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/firebase_options.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../models/app_user_model.dart';
import 'auth_datasource.dart';

/// تسجيل الدخول الحقيقي بـ Firebase Auth (إيميل + باسورد).
/// الاسم والدور (مندوب/أدمن) متخزنين في Firestore: users/{uid}.
class FirebaseAuthDataSource implements AuthDataSource {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  bool _googleInit = false;

  UserRole _roleFor(String email) =>
      kAdminEmails.map((e) => e.toLowerCase()).contains(email.toLowerCase())
          ? UserRole.admin
          : UserRole.rep;

  Future<AppUser> _profile(User u, {String? name}) async {
    final ref = _db.collection('users').doc(u.uid);
    final snap = await ref.get();
    if (snap.exists) {
      return AppUserModel.fromFirestore(snap.data()!, u.uid);
    }
    final user = AppUserModel(
      uid: u.uid,
      email: u.email ?? '',
      name: name ?? u.displayName ?? (u.email ?? '').split('@').first,
      role: _roleFor(u.email ?? ''),
    );
    await ref.set(user.toFirestore());
    return user;
  }

  AuthFailure _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthFailure(tr('الإيميل مش مكتوب صح', 'The email is not valid'));
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthFailure(tr('الإيميل أو الباسورد غلط', 'Wrong email or password'));
      case 'unauthorized-domain':
        return AuthFailure(tr('الدومين ده مش مضاف في Firebase (Authorized domains)', 'This domain is not added in Firebase (Authorized domains)'));
      case 'email-already-in-use':
        return AuthFailure(tr('الإيميل ده مسجل قبل كده', 'This email is already registered'));
      case 'weak-password':
        return AuthFailure(tr('الباسورد ضعيف، لازم 6 حروف أو أرقام على الأقل', 'Weak password, use at least 6 characters'));
      case 'network-request-failed':
        return AuthFailure(tr('مفيش اتصال بالإنترنت', 'No internet connection'));
      case 'too-many-requests':
        return AuthFailure(tr('محاولات كتير، جرّب بعد شوية', 'Too many attempts, try again later'));
      case 'operation-not-allowed':
        return AuthFailure(tr('الطريقة دي مش مفعّلة في Firebase (Authentication > Sign-in method)', 'This method is not enabled in Firebase (Authentication > Sign-in method)'));
      default:
        return AuthFailure(tr('حصلت مشكلة (${e.code})', 'Something went wrong (${e.code})'));
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    final u = await _auth.authStateChanges().first;
    if (u == null) return null;
    try {
      return await _profile(u);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return await _profile(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user!.updateDisplayName(name.trim());
      return await _profile(cred.user!, name: name.trim());
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  /// جوجل: على الويب نافذة منبثقة، وعلى الموبايل الـ picker الأصلي بتاع الجهاز
  /// (google_sign_in plugin) وبعدين نبعت التوكن لـ Firebase.
  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        final cred = await _auth.signInWithPopup(provider);
        return await _profile(cred.user!);
      }
      if (!_googleInit) {
        await GoogleSignIn.instance.initialize();
        _googleInit = true;
      }
      final googleUser = await GoogleSignIn.instance.authenticate();
      final cred = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: googleUser.authentication.idToken,
        ),
      );
      return await _profile(cred.user!);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthFailure(tr('اتلغى تسجيل جوجل', 'Google sign-in was cancelled'));
      }
      throw AuthFailure(tr('حصلت مشكلة في تسجيل جوجل (${e.code.name})', 'Google sign-in failed (${e.code.name})'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request' ||
          e.code == 'canceled') {
        throw AuthFailure(tr('اتلغى تسجيل جوجل', 'Google sign-in was cancelled'));
      }
      throw _map(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
