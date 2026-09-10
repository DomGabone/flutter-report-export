import 'report_column.dart';
import 'report_exporter.dart';

enum ExportKind { csv, pdf }

class RecordedExport {
  const RecordedExport(this.kind, this.spec);

  final ExportKind kind;
  final ReportSpec spec;
}

class RecordingReportExporter implements ReportExporter {
  RecordingReportExporter({this.failWith});

  final Object? failWith;
  final List<RecordedExport> calls = [];

  Iterable<RecordedExport> get csvCalls =>
      calls.where((c) => c.kind == ExportKind.csv);

  Iterable<RecordedExport> get pdfCalls =>
      calls.where((c) => c.kind == ExportKind.pdf);

  @override
  Future<void> shareCsv(ReportSpec spec) => _record(ExportKind.csv, spec);

  @override
  Future<void> sharePdf(ReportSpec spec) => _record(ExportKind.pdf, spec);

  Future<void> _record(ExportKind kind, ReportSpec spec) async {
    calls.add(RecordedExport(kind, spec));
    final failure = failWith;
    if (failure != null) throw failure;
  }
}
