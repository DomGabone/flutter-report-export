import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import 'report_column.dart';

class CsvTableEncoder {
  const CsvTableEncoder({this.fieldDelimiter = ';', this.withBom = true});

  final String fieldDelimiter;
  final bool withBom;

  static const List<int> _utf8Bom = [0xEF, 0xBB, 0xBF];

  String encodeText(ReportSpec spec) {
    final converter = ListToCsvConverter(
      fieldDelimiter: fieldDelimiter,
      eol: '\r\n',
    );
    return converter.convert([spec.headers, ...spec.body]);
  }

  Uint8List encodeBytes(ReportSpec spec) {
    final text = utf8.encode(encodeText(spec));
    if (!withBom) return Uint8List.fromList(text);
    return Uint8List.fromList([..._utf8Bom, ...text]);
  }
}
