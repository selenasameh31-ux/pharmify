import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';

import 'package:pharma_orders/features/orders/domain/entities/order.dart';

/// بيبني ملف .xlsx حقيقي فيه كل الطلبيات: صف لكل صنف في كل طلب.
/// مكتوب يدويًا (zip + XML) بدل حزمة excel لأنها بتتعارض مع نسخة archive الحديثة.
Uint8List buildOrdersExcel(List<Order> orders) {
  final df = DateFormat('yyyy-MM-dd HH:mm');
  final sorted = [...orders]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final rows = <List<Object?>>[
    ['Order ID', 'Date', 'Rep', 'Doctor', 'Medicine', 'Packs', 'Unit Price',
     'Item Total', 'Order Total', 'Notes', 'Status'],
    for (final o in sorted)
      for (final i in o.items)
        [o.id, df.format(o.createdAt), o.repName, o.doctorName, i.medicineName,
         i.quantity, i.unitPrice, i.total, o.totalValue, o.notes,
         o.pending ? 'Pending sync' : 'Synced'],
  ];

  String col(int i) => String.fromCharCode('A'.codeUnitAt(0) + i);
  String esc(String s) => const HtmlEscape(HtmlEscapeMode.unknown).convert(s);

  final sb = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<sheetData>');
  for (var r = 0; r < rows.length; r++) {
    sb.write('<row r="${r + 1}">');
    for (var c = 0; c < rows[r].length; c++) {
      final v = rows[r][c];
      final ref = '${col(c)}${r + 1}';
      if (v is num) {
        sb.write('<c r="$ref"><v>$v</v></c>');
      } else {
        sb.write('<c r="$ref" t="inlineStr"><is><t>${esc(v?.toString() ?? '')}</t></is></c>');
      }
    }
    sb.write('</row>');
  }
  sb.write('</sheetData></worksheet>');

  Uint8List f(String s) => Uint8List.fromList(utf8.encode(s));
  final files = <String, Uint8List>{
    '[Content_Types].xml': f('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '</Types>'),
    '_rels/.rels': f('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>'),
    'xl/workbook.xml': f('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets><sheet name="Orders" sheetId="1" r:id="rId1"/></sheets></workbook>'),
    'xl/_rels/workbook.xml.rels': f('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        '</Relationships>'),
    'xl/worksheets/sheet1.xml': f(sb.toString()),
  };

  final arc = Archive();
  files.forEach((name, data) =>
      arc.addFile(ArchiveFile(name, data.length, data)));
  return Uint8List.fromList(ZipEncoder().encode(arc));
}
