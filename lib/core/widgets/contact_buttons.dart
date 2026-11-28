import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pharma_orders/core/utils/phone.dart';
import 'package:pharma_orders/core/widgets/common.dart';

/// بيفتح واتساب على رقم الدكتور، ولو فيه [text] بيتكتب جاهز في الرسالة.
Future<void> openWhatsApp(BuildContext context, String phone, {String? text}) async {
  var url = 'https://wa.me/${toInternational(phone)}';
  if (text != null && text.isNotEmpty) url += '?text=${Uri.encodeComponent(text)}';
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && context.mounted) {
    showSnack(context, tr('مقدرتش أفتح الرابط على الجهاز ده', 'Couldn\'t open the link on this device'));
  }
}

/// زرار اتصال + زرار واتساب لرقم تليفون.
/// بيستخدم مكتبة url_launcher: tel: بيفتح تطبيق الاتصال في الموبايل،
/// و https://wa.me/... بيفتح واتساب (أو واتساب ويب على الكمبيوتر).
class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key, required this.phone, this.compact = false});

  final String phone;
  final bool compact; // true = أيقونات صغيرة للقوايم

  Future<void> _open(BuildContext context, Uri uri) async {
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      showSnack(context, tr('مقدرتش أفتح الرابط على الجهاز ده', 'Couldn\'t open the link on this device'));
    }
  }

  void _call(BuildContext context) =>
      _open(context, Uri(scheme: 'tel', path: dialable(phone)));

  void _whatsapp(BuildContext context) =>
      _open(context, Uri.parse('https://wa.me/${toInternational(phone)}'));

  @override
  Widget build(BuildContext context) {
    if (phone.trim().isEmpty) return const SizedBox.shrink();
    const green = Color(0xFF25D366);
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: tr('اتصال', 'Call'),
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.call_rounded,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () => _call(context),
          ),
          IconButton(
            tooltip: tr('واتساب', 'WhatsApp'),
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chat_rounded, color: Color(0xFF1FAF54)),
            onPressed: () => _whatsapp(context),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            onPressed: () => _call(context),
            icon: const Icon(Icons.call_rounded),
            label: Text(tr('اتصال', 'Call')),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _whatsapp(context),
            icon: const Icon(Icons.chat_rounded),
            label: Text(tr('واتساب', 'WhatsApp')),
          ),
        ),
      ],
    );
  }
}
