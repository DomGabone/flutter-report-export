typedef ReportRow = Map<String, Object?>;

typedef ReportCellFormatter = String Function(Object? value, ReportRow row);

class ReportColumn {
  const ReportColumn({required this.key, required this.header, this.format});

  final String key;
  final String header;
  final ReportCellFormatter? format;

  String resolve(ReportRow row) {
    final raw = row[key];
    final formatter = format;
    if (formatter != null) return formatter(raw, row);
    if (raw == null) return '';
    return raw.toString();
  }
}

class ReportTotal {
  const ReportTotal({required this.label, required this.value});

  final String label;
  final String value;
}

class ReportSpec {
  const ReportSpec({
    required this.fileName,
    required this.title,
    required this.columns,
    required this.rows,
    this.subtitle,
    this.issuer,
    this.totals = const [],
  });

  final String fileName;
  final String title;
  final String? subtitle;
  final String? issuer;
  final List<ReportColumn> columns;
  final List<ReportRow> rows;
  final List<ReportTotal> totals;

  List<String> get headers => columns.map((c) => c.header).toList();

  List<List<String>> get body => [
    for (final row in rows) columns.map((c) => c.resolve(row)).toList(),
  ];
}
