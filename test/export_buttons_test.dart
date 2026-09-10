import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:report_export/report_export.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    required bool busy,
    required ExportAction onPdf,
    ExportAction? onCsv,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportButtons(busy: busy, onPdf: onPdf, onCsv: onCsv),
        ),
      ),
    );
  }

  Future<String?> ok() async => null;

  final pdfButton = find.byWidgetPredicate((w) => w is FilledButton);
  final csvButton = find.byWidgetPredicate((w) => w is OutlinedButton);

  group('ExportButtons', () {
    testWidgets('PDF e a acao principal e CSV a secundaria', (tester) async {
      await mount(tester, busy: false, onPdf: ok, onCsv: ok);
      expect(pdfButton, findsOneWidget);
      expect(csvButton, findsOneWidget);
      expect(find.text('Gerar PDF'), findsOneWidget);
      expect(find.text('Planilha'), findsOneWidget);
    });

    testWidgets('sem CSV o PDF ocupa a largura toda', (tester) async {
      await mount(tester, busy: false, onPdf: ok);
      expect(pdfButton, findsOneWidget);
      expect(csvButton, findsNothing);
      expect(
        find.ancestor(
          of: pdfButton,
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == double.infinity,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('ocupado desabilita ambos', (tester) async {
      await mount(tester, busy: true, onPdf: ok, onCsv: ok);
      expect((tester.widget(pdfButton) as FilledButton).onPressed, isNull);
      expect((tester.widget(csvButton) as OutlinedButton).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('erro devolvido pela acao aparece no lugar da confirmacao', (
      tester,
    ) async {
      await mount(
        tester,
        busy: false,
        onPdf: () async => 'Nenhuma venda no período.',
      );
      await tester.tap(pdfButton);
      await tester.pump();
      expect(find.text('Nenhuma venda no período.'), findsOneWidget);
      expect(find.textContaining('PDF gerado'), findsNothing);
    });

    testWidgets('cada botao dispara a propria acao', (tester) async {
      var pdfCalls = 0;
      var csvCalls = 0;
      await mount(
        tester,
        busy: false,
        onPdf: () async {
          pdfCalls++;
          return null;
        },
        onCsv: () async {
          csvCalls++;
          return null;
        },
      );
      await tester.tap(csvButton);
      await tester.pump();
      expect(csvCalls, 1);
      expect(pdfCalls, 0);
      expect(find.textContaining('Planilha gerada'), findsOneWidget);
    });
  });

  group('RecordingReportExporter', () {
    const spec = ReportSpec(
      fileName: 'x',
      title: 'x',
      columns: [ReportColumn(key: 'a', header: 'A')],
      rows: [],
    );

    test('grava as chamadas na ordem', () async {
      final exporter = RecordingReportExporter();
      await exporter.sharePdf(spec);
      await exporter.shareCsv(spec);
      expect(exporter.calls.map((c) => c.kind), [
        ExportKind.pdf,
        ExportKind.csv,
      ]);
      expect(exporter.pdfCalls.length, 1);
    });

    test('pode simular falha depois de gravar', () async {
      final exporter = RecordingReportExporter(
        failWith: StateError('sem disco'),
      );
      await expectLater(exporter.shareCsv(spec), throwsStateError);
      expect(exporter.csvCalls.length, 1);
    });
  });
}
