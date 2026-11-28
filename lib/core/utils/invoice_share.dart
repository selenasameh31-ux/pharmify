import 'package:flutter/services.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';

import 'package:pharma_orders/features/orders/domain/entities/order.dart';
import 'package:pharma_orders/core/utils/invoice_pdf.dart';

/// بيعمل فاتورة PDF للطلبية ويفتح المشاركة (واتساب وغيره على الموبايل).
/// على الويب/الديسكتوب بينزّل الملف أو يفتح معاينة الطباعة.
Future<void> shareInvoice(BuildContext context, Order order) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await buildInvoicePdf(
      order,
      regularFont: await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'),
      boldFont: await rootBundle.load('assets/fonts/NotoSansArabic-Bold.ttf'),
      latinRegular: await rootBundle.load('assets/fonts/Tajawal-Regular.ttf'),
      latinBold: await rootBundle.load('assets/fonts/Tajawal-Bold.ttf'),
    );
    final name = 'invoice-${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id}.pdf';
    try {
      await Printing.sharePdf(bytes: bytes, filename: name);
    } catch (_) {
      // بعض المنصات (زي ويندوز) مفيهاش مشاركة: نفتح معاينة الطباعة/الحفظ كـ PDF
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
    }
  } catch (_) {
    messenger.showSnackBar(
        SnackBar(content: Text(tr('تعذر عمل الفاتورة، جرّب تاني', 'Couldn\'t create the invoice, try again'))));
  }
}
