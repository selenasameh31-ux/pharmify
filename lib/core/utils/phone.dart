/// يحول الرقم المصري للصيغة الدولية اللي واتساب بيفهمها (من غير + ولا مسافات).
/// 01012345678  ->  201012345678
String toInternational(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (d.startsWith('+')) return d.substring(1);
  if (d.startsWith('00')) return d.substring(2);
  if (d.startsWith('0')) return '20${d.substring(1)}';
  return d;
}

/// الرقم بدون مسافات أو رموز، مناسب لفتح الاتصال.
String dialable(String raw) => raw.replaceAll(RegExp(r'[^0-9+]'), '');
