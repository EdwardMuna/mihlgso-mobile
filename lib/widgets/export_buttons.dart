import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';

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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _ExportChip(
          label: 'Excel',
          tooltip: strings.exportExcelTooltip,
          icon: Icons.grid_on,
          color: const Color(0xFF1D6F42),
          onPressed: onExcel,
        ),
        _ExportChip(
          label: 'PDF',
          tooltip: strings.exportPdfTooltip,
          icon: Icons.picture_as_pdf_outlined,
          color: const Color(0xFFD32F2F),
          onPressed: onPdf,
        ),
        _ExportChip(
          label: 'CSV',
          tooltip: strings.exportCsvTooltip,
          icon: Icons.description_outlined,
          color: const Color(0xFF0E5A8A),
          onPressed: onCsv,
        ),
      ],
    );
  }
}

class _ExportChip extends StatelessWidget {
  const _ExportChip({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
