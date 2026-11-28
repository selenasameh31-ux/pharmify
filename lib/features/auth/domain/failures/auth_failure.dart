/// رسالة خطأ جاهزة بالعربي تتعرض للمستخدم.
class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}
