import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';

/// Excel/PDF/CSV export buttons — shared by the admin Payments, Donations,
/// and Applications screens. Each callback should export whatever the
/// screen's currently *visible* (filtered) rows are, not the unfiltered list,
/// and resolve once the file has actually been saved (so the chip's own
/// loading/success animation reflects real completion, not just the tap).
class ExportButtonsRow extends StatelessWidget {
  const ExportButtonsRow({
    super.key,
    required this.onExcel,
    required this.onPdf,
    required this.onCsv,
  });

  final Future<void> Function() onExcel;
  final Future<void> Function() onPdf;
  final Future<void> Function() onCsv;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _ExportChip(label: 'Excel', tooltip: strings.exportExcelTooltip, icon: Icons.grid_on, color: const Color(0xFF1D6F42), onPressed: onExcel),
        _ExportChip(label: 'PDF', tooltip: strings.exportPdfTooltip, icon: Icons.picture_as_pdf_outlined, color: const Color(0xFFD32F2F), onPressed: onPdf),
        _ExportChip(label: 'CSV', tooltip: strings.exportCsvTooltip, icon: Icons.description_outlined, color: const Color(0xFF0E5A8A), onPressed: onCsv),
      ],
    );
  }
}

enum _ChipState { idle, loading, success }

class _ExportChip extends StatefulWidget {
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
  final Future<void> Function() onPressed;

  @override
  State<_ExportChip> createState() => _ExportChipState();
}

class _ExportChipState extends State<_ExportChip> {
  _ChipState _state = _ChipState.idle;

  Future<void> _handleTap() async {
    if (_state != _ChipState.idle) return;
    setState(() => _state = _ChipState.loading);
    try {
      await widget.onPressed();
      if (!mounted) return;
      setState(() => _state = _ChipState.success);
      await Future.delayed(const Duration(milliseconds: 900));
    } finally {
      if (mounted) setState(() => _state = _ChipState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return Tooltip(
      message: widget.tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: switch (_state) {
                    _ChipState.idle => Icon(widget.icon, size: 16, color: color, key: const ValueKey('idle')),
                    _ChipState.loading => SizedBox(
                        key: const ValueKey('loading'),
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: color),
                      ),
                    _ChipState.success => Icon(Icons.check_circle, size: 16, color: color, key: const ValueKey('success')),
                  },
                ),
                const SizedBox(width: 4),
                Text(widget.label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
