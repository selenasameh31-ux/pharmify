import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/features/orders/domain/entities/order.dart';

/// بيعمل فاتورة PDF للطلبية. الخط (Tajawal) بيتبعت من برّه عشان الدالة
/// دي تفضل Dart صافي وتتجرب بسهولة.
Future<Uint8List> buildInvoicePdf(
  Order order, {
  required ByteData regularFont,
  required ByteData boldFont,
  required ByteData latinRegular,
  required ByteData latinBold,
}) async {
  // الخط الأساسي Noto Sans Arabic (فيه كل أشكال الحروف العربي، منها ي المنفردة)،
  // وTajawal احتياطي للحروف اللاتينية والرموز اللي مش موجودة فيه.
  final regular = pw.Font.ttf(regularFont);
  final bold = pw.Font.ttf(boldFont);
  final fbRegular = pw.Font.ttf(latinRegular);
  final fbBold = pw.Font.ttf(latinBold);
  final doc = pw.Document(
    title: tr('فاتورة ${order.doctorName}', 'Invoice ${order.doctorName}'),
    author: 'Pharmify',
    theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        fontFallback: [fbRegular, fbBold]),
  );

  const teal = PdfColor.fromInt(0xFF0B7A75);
  const amber = PdfColor.fromInt(0xFFFFB02E);
  const soft = PdfColor.fromInt(0xFFE8F4F3);
  final money = NumberFormat('#,##0.##', 'en_US');
  final d = order.createdAt;
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final dateText =
      '${d.day}/${d.month}/${d.year}  $h12:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
  final hasPrices = order.totalValue > 0;
  final invoiceNo = order.id.length > 6
      ? order.id.substring(order.id.length - 6)
      : order.id;

  // النص اللاتيني جوه فقرة عربي بيتعكس في مكتبة pdf، فبنعرضه LTR صريح.
  final latin = RegExp(r'[A-Za-z]');
  final arabic = RegExp(r'[\u0600-\u06FF]');
  pw.Widget mixed(String t, pw.TextStyle style) {
    final t2 = t.trim();
    // عربي: دايمًا RTL (حتى في الفاتورة الإنجليزي)، ولاتيني بس: دايمًا LTR
    final dir = arabic.hasMatch(t2)
        ? pw.TextDirection.rtl
        : (latin.hasMatch(t2) ? pw.TextDirection.ltr : null);
    if (dir == null) return pw.Text(t2, style: style);
    return pw.Directionality(textDirection: dir, child: pw.Text(t2, style: style));
  }

  pw.Widget labeled(String label, String value, pw.TextStyle style) =>
      pw.Row(children: [
        pw.Text('$label ', style: style),
        mixed(value, style),
      ]);

  // pw.Table مبيعكسش الأعمدة في العربي لوحده: بنقلب ترتيب الخلايا بنفسنا
  // (الدوا أقصى اليمين والإجمالي أقصى الشمال). والعرض بنقلبه كمان.
  List<pw.Widget> rowCells(List<pw.Widget> c) => lang.isAr ? c.reversed.toList() : c;

  pw.Widget cell(String text,
      {bool head = false, pw.Alignment? align}) {
    return pw.Container(
      alignment: align ?? (lang.isAr ? pw.Alignment.centerRight : pw.Alignment.centerLeft),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: mixed(
          text,
          pw.TextStyle(
              fontSize: head ? 12 : 12,
              fontWeight: head ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: head ? PdfColors.white : PdfColors.black)),
    );
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      textDirection: lang.isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // الهيدر
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
                color: teal, borderRadius: pw.BorderRadius.circular(14)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(tr('فاتورة طلبية', 'Order invoice'),
                        style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text(tr('رقم $invoiceNo', 'No. $invoiceNo'),
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.white)),
                  ],
                ),
                pw.Directionality(
                  textDirection: pw.TextDirection.ltr,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(
                          font: fbBold,
                          fontSize: 26,
                          color: PdfColors.white),
                      children: [
                        const pw.TextSpan(text: 'Pharm'),
                        pw.TextSpan(
                            text: 'ify',
                            style: const pw.TextStyle(color: amber)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          // بيانات الطلبية
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
                color: soft, borderRadius: pw.BorderRadius.circular(12)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                labeled(tr('الدكتور:', 'Doctor:'), order.doctorName,
                    pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                if (order.repName.isNotEmpty)
                  labeled(tr('المندوب:', 'Rep:'), order.repName,
                      const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 3),
                pw.Row(children: [
                  pw.Text(tr('التاريخ: ', 'Date: '), style: const pw.TextStyle(fontSize: 12)),
                  pw.Directionality(
                    textDirection: pw.TextDirection.ltr,
                    child: pw.Text(dateText,
                        style: const pw.TextStyle(fontSize: 12)),
                  ),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          // جدول الأدوية
          pw.Table(
            columnWidths: {
              for (final e in {
                0: 4.0,
                1: 1.4,
                if (hasPrices) 2: 1.8,
                if (hasPrices) 3: 2.0,
              }.entries)
                (lang.isAr ? (hasPrices ? 3 : 1) - e.key : e.key): pw.FlexColumnWidth(e.value),
            },
            border: const pw.TableBorder(
              horizontalInside:
                  pw.BorderSide(color: PdfColors.grey300, width: .6),
              bottom: pw.BorderSide(color: PdfColors.grey400, width: .8),
            ),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: teal, borderRadius: pw.BorderRadius.circular(8)),
                children: rowCells([
                  cell(tr('الدوا', 'Medicine'), head: true),
                  cell(tr('الكمية', 'Qty'), head: true, align: pw.Alignment.center),
                  if (hasPrices)
                    cell(tr('سعر العبوة', 'Unit price'), head: true, align: pw.Alignment.center),
                  if (hasPrices)
                    cell(tr('الإجمالي', 'Total'), head: true, align: pw.Alignment.center),
                ]),
              ),
              for (final it in order.items)
                pw.TableRow(
                    children: rowCells([
                  cell(it.medicineName),
                  cell('${it.quantity}', align: pw.Alignment.center),
                  if (hasPrices)
                    cell(money.format(it.unitPrice),
                        align: pw.Alignment.center),
                  if (hasPrices)
                    cell(money.format(it.total), align: pw.Alignment.center),
                ])),
            ],
          ),
          pw.SizedBox(height: 16),
          // الإجمالي
          pw.Align(
            alignment: lang.isAr ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
            child: pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: pw.BoxDecoration(
                  color: soft,
                  border: pw.Border.all(color: teal, width: 1),
                  borderRadius: pw.BorderRadius.circular(12)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(tr('إجمالي العبوات: ${order.totalQuantity}', 'Total packs: ${order.totalQuantity}'),
                      style: const pw.TextStyle(fontSize: 12)),
                  if (hasPrices) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(tr('الإجمالي: ${money.format(order.totalValue)} ج.م', 'Total: ${money.format(order.totalValue)} EGP'),
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: teal)),
                  ],
                ],
              ),
            ),
          ),
          if (order.notes.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            labeled(tr('ملاحظات:', 'Notes:'), order.notes, const pw.TextStyle(fontSize: 12)),
          ],
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey400),
          pw.Center(
            child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
              pw.Text(tr('تم إنشاء الفاتورة من تطبيق ', 'Invoice created with '),
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
              pw.Directionality(
                textDirection: pw.TextDirection.ltr,
                child: pw.Text('Pharmify',
                    style: pw.TextStyle(
                        font: fbRegular,
                        fontSize: 10,
                        color: PdfColors.grey700)),
              ),
            ]),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
