import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_orders/features/statistics/data/orders_excel_exporter.dart';
import 'package:pharma_orders/features/orders/domain/entities/order.dart';

void main() {
  test('builds a valid xlsx', () {
    final bytes = buildOrdersExcel([
      Order(
        id: 'o1', repId: 'r1', repName: 'Selena', doctorId: 'd1',
        doctorName: 'د. أحمد منصور', notes: 'note "quoted" <xml>',
        createdAt: DateTime(2026, 11, 25, 13, 5), pending: false,
        items: const [
          OrderItem(medicineId: 'm1', medicineName: 'كونكور 5 مجم', quantity: 4, unitPrice: 140.0),
          OrderItem(medicineId: 'm2', medicineName: 'Panadol', quantity: 3, unitPrice: 62.0),
        ],
      ),
    ]);
    expect(bytes.length, greaterThan(500));
    File('/tmp/orders_test.xlsx').writeAsBytesSync(bytes);
  });
}
