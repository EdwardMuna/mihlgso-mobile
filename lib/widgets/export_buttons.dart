import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';

/// Excel/PDF/CSV export buttons — shared by the admin Payments, Donations,
/// and Applications screens. Each callback should export whatever the
/// screen's currently *visible* (filtered) rows are, not the unfiltered list.
class ExportButtonsRow extends StatelessWidget {
  const ExportButtonsRow({
    super.key,
    required this.onExcel,
    required this.onPdf,
    required this.onCsv,
  });

  final VoidCallback onExcel;
  final VoidCallback onPdf;
  final VoidCallback onCsv;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: strings.exportExcelTooltip,
          icon: const Icon(Icons.grid_on, color: Color(0xFF1D6F42)),
          visualDensity: VisualDensity.compact,
          onPressed: onExcel,
        ),
        IconButton(
          tooltip: strings.exportPdfTooltip,
          icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFD32F2F)),
          visualDensity: VisualDensity.compact,
          onPressed: onPdf,
        ),
        IconButton(
          tooltip: strings.exportCsvTooltip,
          icon: const Icon(Icons.description_outlined, color: Color(0xFF0E5A8A)),
          visualDensity: VisualDensity.compact,
          onPressed: onCsv,
        ),
      ],
    );
  }
}
