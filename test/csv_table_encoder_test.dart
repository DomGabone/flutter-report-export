import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:report_export/report_export.dart';

ReportSpec _spec({List<ReportRow>? rows}) => ReportSpec(
  fileName: 'vendas',
  title: 'Vendas do dia',
  columns: [
    const ReportColumn(key: 'item', header: 'Item'),
    const ReportColumn(key: 'qtd', header: 'Quantidade'),
    ReportColumn(
      key: 'total',
      header: 'Total (R\$)',
      format: (value, _) => (value as num).toStringAsFixed(2),
    ),
  ],
  rows:
      rows ??
      [
        {'item': 'Pão francês', 'qtd': 120, 'total': 96.0},
        {'item': 'Bolo; fatia', 'qtd': 8, 'total': 64.5},
        {'item': 'Café "coado"', 'qtd': null, 'total': 0},
      ],
);

void main() {
  group('CsvTableEncoder', () {
    test('usa ponto e virgula, CRLF e cabecalho na primeira linha', () {
      final text = const CsvTableEncoder().encodeText(_spec());
      final lines = text.split('\r\n');
      expect(lines.first, 'Item;Quantidade;Total (R\$)');
      expect(lines[1], 'Pão francês;120;96.00');
    });

    test('escapa delimitador e aspas dentro do campo', () {
      final text = const CsvTableEncoder().encodeText(_spec());
      expect(text, contains('"Bolo; fatia";8;64.50'));
      expect(text, contains('"Café ""coado""";;0.00'));
    });

    test('valor nulo vira campo vazio, formatador ainda roda', () {
      final text = const CsvTableEncoder().encodeText(_spec());
      expect(text, contains(';;0.00'));
    });

    test('bytes comecam com BOM UTF-8 por padrao e sem BOM quando pedido', () {
      final withBom = const CsvTableEncoder().encodeBytes(_spec());
      expect(withBom.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(withBom.sublist(3)), startsWith('Item;'));

      final plain = const CsvTableEncoder(withBom: false).encodeBytes(_spec());
      expect(utf8.decode(plain), startsWith('Item;'));
    });

    test('delimitador configuravel', () {
      final text = const CsvTableEncoder(fieldDelimiter: ',').encodeText(
        _spec(
          rows: [
            {'item': 'x', 'qtd': 1, 'total': 1},
          ],
        ),
      );
      expect(text.split('\r\n').first, 'Item,Quantidade,Total (R\$)');
    });
  });

  group('ReportColumn', () {
    test('resolve sem formatador usa toString e trata nulo', () {
      const column = ReportColumn(key: 'k', header: 'K');
      expect(column.resolve({'k': 42}), '42');
      expect(column.resolve({'k': null}), '');
      expect(column.resolve({}), '');
    });

    test('formatador recebe a linha inteira', () {
      final column = ReportColumn(
        key: 'preco',
        header: 'Preço',
        format: (value, row) => '${row['moeda']} $value',
      );
      expect(column.resolve({'preco': 10, 'moeda': 'R\$'}), 'R\$ 10');
    });
  });
}
