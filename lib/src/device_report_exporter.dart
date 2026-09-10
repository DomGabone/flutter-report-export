import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'csv_table_encoder.dart';
import 'pdf_report_builder.dart';
import 'report_column.dart';
import 'report_exporter.dart';

class DeviceReportExporter implements ReportExporter {
  const DeviceReportExporter({
    this.csv = const CsvTableEncoder(),
    this.pdf = const PdfReportBuilder(),
  });

  final CsvTableEncoder csv;
  final PdfReportBuilder pdf;

  @override
  Future<void> shareCsv(ReportSpec spec) async {
    final bytes = csv.encodeBytes(spec);
    final name = '${spec.fileName}.csv';
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'text/csv', name: name)],
        fileNameOverrides: [name],
        subject: spec.title,
      ),
    );
  }

  @override
  Future<void> sharePdf(ReportSpec spec) async {
    final bytes = await pdf.buildBytes(spec);
    await Printing.sharePdf(bytes: bytes, filename: '${spec.fileName}.pdf');
  }
}
