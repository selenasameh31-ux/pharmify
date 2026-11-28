import '../../domain/entities/app_user.dart';

/// نموذج طبقة البيانات لـ AppUser: يضيف التحويل من/إلى JSON وFirestore.
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
  });

  factory AppUserModel.fromEntity(AppUser u) => AppUserModel(
      uid: u.uid, email: u.email, name: u.name, role: u.role);

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': isAdmin ? 'admin' : 'rep',
      };

  /// نفس شكل التخزين في Firestore (users/{uid}).
  Map<String, dynamic> toFirestore() => toJson();

  factory AppUserModel.fromJson(Map<String, dynamic> j) => AppUserModel(
        uid: j['uid'] as String,
        email: (j['email'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        role: j['role'] == 'admin' ? UserRole.admin : UserRole.rep,
      );

  factory AppUserModel.fromFirestore(Map<String, dynamic> data, String uid) =>
      AppUserModel.fromJson({...data, 'uid': uid});
}
