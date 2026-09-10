import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:report_export/report_export.dart';

void main() {
  final spec = ReportSpec(
    fileName: 'fechamento',
    title: 'Fechamento de caixa',
    subtitle: 'Turno da manhã',
    issuer: 'Padaria Grão Dourado',
    columns: const [
      ReportColumn(key: 'item', header: 'Item'),
      ReportColumn(key: 'qtd', header: 'Qtd'),
    ],
    rows: List.generate(120, (i) => {'item': 'Produto $i', 'qtd': i}),
    totals: const [ReportTotal(label: 'Total do turno', value: 'R\$ 1.234,56')],
  );

  group('PdfReportBuilder', () {
    test('gera um PDF valido com varias paginas', () async {
      final bytes = await const PdfReportBuilder().buildBytes(spec);
      expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
      final text = latin1.decode(bytes, allowInvalid: true);
      expect(
        RegExp(r'/Type\s*/Page[^s]').allMatches(text).length,
        greaterThan(1),
      );
    });

    test('relogio injetavel deixa o carimbo deterministico', () {
      final builder = PdfReportBuilder(clock: () => DateTime(2030, 1, 2, 3, 4));
      expect(
        PdfReportBuilder.formatStamp(builder.clock!()),
        '02/01/2030 03:04',
      );
    });

    test('metadados do documento levam titulo e emissor', () async {
      final bytes = await const PdfReportBuilder().buildBytes(spec);
      final text = latin1.decode(bytes, allowInvalid: true);
      expect(text, contains('/Title'));
      expect(text, contains('/Author'));
    });
  });

  group('ReportSpec', () {
    test('headers e body seguem a ordem das colunas', () {
      expect(spec.headers, ['Item', 'Qtd']);
      expect(spec.body.first, ['Produto 0', '0']);
      expect(spec.body.length, 120);
    });
  });
}
