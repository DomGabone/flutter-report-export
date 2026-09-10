import 'package:flutter/material.dart';

typedef ExportAction = Future<String?> Function();

class ExportButtons extends StatelessWidget {
  const ExportButtons({
    super.key,
    required this.busy,
    required this.onPdf,
    this.onCsv,
    this.pdfLabel = 'Gerar PDF',
    this.csvLabel = 'Planilha',
    this.pdfDoneMessage = 'PDF gerado. Escolha onde salvar ou enviar.',
    this.csvDoneMessage = 'Planilha gerada. Escolha onde salvar ou enviar.',
  });

  final bool busy;
  final ExportAction onPdf;
  final ExportAction? onCsv;
  final String pdfLabel;
  final String csvLabel;
  final String pdfDoneMessage;
  final String csvDoneMessage;

  Future<void> _run(
    BuildContext context,
    ExportAction action,
    String doneMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await action();
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(error ?? doneMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final csv = onCsv;

    final pdfButton = SizedBox(
      height: 46,
      child: FilledButton.icon(
        onPressed: busy ? null : () => _run(context, onPdf, pdfDoneMessage),
        icon: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.picture_as_pdf_outlined, size: 16),
        label: Text(pdfLabel),
      ),
    );

    if (csv == null) {
      return SizedBox(width: double.infinity, child: pdfButton);
    }

    return Row(
      children: [
        Expanded(flex: 2, child: pdfButton),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _run(context, csv, csvDoneMessage),
              icon: const Icon(Icons.grid_on_outlined, size: 16),
              label: Text(csvLabel, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}
