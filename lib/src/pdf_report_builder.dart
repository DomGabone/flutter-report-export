import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_column.dart';

class PdfReportBuilder {
  const PdfReportBuilder({
    this.pageFormat = PdfPageFormat.a4,
    this.headerColor = PdfColors.grey900,
    this.clock,
  });

  final PdfPageFormat pageFormat;
  final PdfColor headerColor;
  final DateTime Function()? clock;

  pw.Document build(ReportSpec spec) {
    final now = (clock ?? DateTime.now)();
    final document = pw.Document(title: spec.title, author: spec.issuer);

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(26),
        header: (_) => _header(spec, now),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Pagina ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: spec.headers,
            data: spec.body,
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: headerColor),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          ),
          if (spec.totals.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  for (final total in spec.totals)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 3),
                      child: pw.Text(
                        '${total.label}: ${total.value}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return document;
  }

  Future<Uint8List> buildBytes(ReportSpec spec) => build(spec).save();

  pw.Widget _header(ReportSpec spec, DateTime now) {
    final issuer = spec.issuer;
    final subtitle = spec.subtitle;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              spec.title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Emitido em ${formatStamp(now)}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        if (issuer != null && issuer.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              issuer,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
            ),
          ),
        if (subtitle != null && subtitle.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(
              subtitle,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Divider(thickness: 0.6, color: PdfColors.grey400),
        ),
      ],
    );
  }

  static String formatStamp(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
