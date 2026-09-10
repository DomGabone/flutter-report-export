import 'package:flutter/material.dart';
import 'package:report_export/report_export.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Relatorio de vendas',
      home: SalesReportPage(exporter: DeviceReportExporter()),
    );
  }
}

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key, required this.exporter});

  final ReportExporter exporter;

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  bool _busy = false;

  static const _sales = <ReportRow>[
    {'item': 'Pão francês', 'qtd': 120, 'total': 96.0},
    {'item': 'Sonho', 'qtd': 14, 'total': 98.0},
    {'item': 'Café coado', 'qtd': 37, 'total': 148.0},
    {'item': 'Bolo de fubá (fatia)', 'qtd': 9, 'total': 67.5},
  ];

  String _money(Object? value, ReportRow _) =>
      'R\$ ${(value as num).toStringAsFixed(2).replaceAll('.', ',')}';

  ReportSpec _spec() {
    final total = _sales.fold<double>(
      0,
      (sum, row) => sum + (row['total'] as num),
    );
    return ReportSpec(
      fileName: 'vendas-do-dia',
      title: 'Vendas do dia',
      subtitle: 'Turno da manhã',
      issuer: 'Padaria Grão Dourado',
      columns: [
        const ReportColumn(key: 'item', header: 'Item'),
        const ReportColumn(key: 'qtd', header: 'Quantidade'),
        ReportColumn(key: 'total', header: 'Total', format: _money),
      ],
      rows: _sales,
      totals: [ReportTotal(label: 'Total do turno', value: _money(total, {}))],
    );
  }

  Future<String?> _guard(Future<void> Function(ReportSpec) action) async {
    if (_sales.isEmpty) return 'Nenhuma venda no período.';
    setState(() => _busy = true);
    try {
      await action(_spec());
      return null;
    } catch (_) {
      return 'Não foi possível gerar o arquivo.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendas do dia')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (final row in _sales)
                    ListTile(
                      title: Text(row['item'].toString()),
                      subtitle: Text('${row['qtd']} un.'),
                      trailing: Text(_money(row['total'], row)),
                    ),
                ],
              ),
            ),
            ExportButtons(
              busy: _busy,
              onPdf: () => _guard(widget.exporter.sharePdf),
              onCsv: () => _guard(widget.exporter.shareCsv),
            ),
          ],
        ),
      ),
    );
  }
}
