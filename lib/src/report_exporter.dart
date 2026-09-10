import 'report_column.dart';

abstract class ReportExporter {
  Future<void> shareCsv(ReportSpec spec);

  Future<void> sharePdf(ReportSpec spec);
}
