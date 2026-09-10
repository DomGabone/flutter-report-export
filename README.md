# report_export

Exportação de relatórios tabulares em **CSV** e **PDF** para Flutter, pensada para ser reaproveitada por qualquer tela que já tenha os dados em memória. O pacote não consulta rede nem banco: recebe linhas e colunas, monta o arquivo e entrega ao compartilhamento do sistema.

O exemplo usa um cenário fictício de padaria, mas o pacote não sabe nada sobre padarias.

## Arquitetura

```
ReportSpec ──► CsvTableEncoder ──► bytes ──┐
           └─► PdfReportBuilder ──► bytes ──┼─► ReportExporter
                                            │     ├─ DeviceReportExporter   (share_plus + printing)
                                            │     └─ RecordingReportExporter (testes)
ExportButtons ◄─── callbacks Future<String?> ◄──┘
```

A montagem do documento é código puro, sem canal de plataforma. Por isso os testes conseguem verificar o CSV byte a byte e abrir o PDF gerado sem emulador.

## Peças

| Peça | Responsabilidade |
|---|---|
| `ReportSpec`, `ReportColumn`, `ReportTotal` | Descrevem o relatório: colunas com formatador opcional, linhas como mapas, totais de rodapé. |
| `CsvTableEncoder` | Gera CSV com `;` como delimitador, `CRLF` e BOM UTF-8, para abrir certo no Excel em português. Tudo configurável. |
| `PdfReportBuilder` | PDF A4 com cabeçalho, emissor, subtítulo, tabela paginada, totais e numeração de página. Relógio injetável. |
| `ReportExporter` | Contrato de entrega. |
| `DeviceReportExporter` | Implementação real via `share_plus` e `printing`. |
| `RecordingReportExporter` | Implementação falsa que grava as chamadas e pode simular falha. |
| `ExportButtons` | Par de botões com hierarquia fixa: PDF preenchido e principal, CSV de contorno e opcional. Recebe callbacks que devolvem `null` em sucesso ou a mensagem de erro. |

## Uso

```dart
final spec = ReportSpec(
  fileName: 'vendas-do-dia',
  title: 'Vendas do dia',
  issuer: 'Minha loja',
  columns: [
    const ReportColumn(key: 'item', header: 'Item'),
    ReportColumn(key: 'total', header: 'Total', format: (v, _) => 'R\$ $v'),
  ],
  rows: vendas,
  totals: [ReportTotal(label: 'Total', value: 'R\$ 409,50')],
);

const exporter = DeviceReportExporter();
await exporter.sharePdf(spec);
```

Na tela:

```dart
ExportButtons(
  busy: carregando,
  onPdf: () async {
    if (vendas.isEmpty) return 'Nenhuma venda no período.';
    await exporter.sharePdf(spec);
    return null;
  },
  onCsv: () async { ... },
)
```

## Decisões de projeto

- **PDF é obrigatório, CSV é complementar.** O widget impõe essa hierarquia e o teste quebra se alguém inverter.
- **Erro vem do chamador, nunca genérico.** O botão mostra exatamente a mensagem que a ação devolveu.
- **Montagem separada da entrega.** Permite testar sem plataforma e trocar o mecanismo de compartilhamento sem tocar na geração.
- **CSV amigável ao Excel brasileiro.** Ponto e vírgula e BOM evitam o problema clássico de acentos quebrados e colunas coladas.

## Rodando

```bash
flutter pub get
flutter analyze
flutter test
```

## Licença

MIT.
