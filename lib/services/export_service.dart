import 'package:excel/excel.dart' as xls;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Mirrors the website's brand gradient sweep (see the Next.js site's
/// components/ui/ExportControls.tsx: GRADIENT_START_RGB/GRADIENT_END_RGB,
/// matching --gradient-blue/--gradient-green in app/globals.css) so the
/// app's exported files look identical to the website's.
class _Brand {
  _Brand._();
  static const gradientStart = PdfColor.fromInt(0xFF107BD9);
  static const gradientEnd = PdfColor.fromInt(0xFF69B249);

  static const _startRgb = (0x10, 0x7B, 0xD9);
  static const _endRgb = (0x69, 0xB2, 0x49);

  static int _lerp(int a, int b, double t) => (a + (b - a) * t.clamp(0, 1)).round();

  /// The gradient's color at fraction [t] (0.0 at the blue end, 1.0 at the
  /// green end) as a PDF color.
  static PdfColor colorAt(double t) {
    final r = _lerp(_startRgb.$1, _endRgb.$1, t);
    final g = _lerp(_startRgb.$2, _endRgb.$2, t);
    final b = _lerp(_startRgb.$3, _endRgb.$3, t);
    return PdfColor.fromInt(0xFF000000 | (r << 16) | (g << 8) | b);
  }

  /// Same, as an ARGB hex string for the `excel` package (which has no
  /// gradient-fill support, so a solid color sampled from the gradient at
  /// each column's midpoint approximates the sweep instead).
  static String hexAt(double t) {
    final r = _lerp(_startRgb.$1, _endRgb.$1, t);
    final g = _lerp(_startRgb.$2, _endRgb.$2, t);
    final b = _lerp(_startRgb.$3, _endRgb.$3, t);
    String hex(int n) => n.toRadixString(16).padLeft(2, '0').toUpperCase();
    return 'FF${hex(r)}${hex(g)}${hex(b)}';
  }

  static const white = 'FFFFFFFF';
}

/// One data row's worth of exportable cells, alongside an optional
/// [totalRow] that gets appended as a final, gradient-highlighted row
/// spanning the same columns (mirrors the website's `totalRow` prop —
/// e.g. blank cells except "Totals" under the name column and the actual
/// sums under the amount columns).
class ExportData {
  const ExportData({required this.headers, required this.rows, this.totalRow});

  final List<String> headers;
  final List<List<String>> rows;
  final List<String>? totalRow;
}

/// Turns an admin list (Payments/Donations/Applications) into a branded
/// Excel or PDF file — matching the website's export design (letterhead
/// header with the org logo, brand-gradient header/total rows, contact-line
/// footer) — and saves it straight to the device's real Downloads folder,
/// no share sheet, no save-location picker, via a native platform channel
/// (see android/.../MainActivity.kt: MediaStore.Downloads on Android 10+,
/// direct file write on 9 and below).
class ExportService {
  ExportService._();

  static const _channel = MethodChannel('mihlgso/downloads');
  static const _orgName = 'MIHLGSO';
  static const _contactLine = 'Mafia Island, Tanzania   •   +255 655 942 925   •   +255 786 552 590';

  static Future<void> _saveToDownloads(String name, List<int> bytes, String mimeType) async {
    await _channel.invokeMethod<String>('saveToDownloads', {
      'name': name,
      'bytes': Uint8List.fromList(bytes),
      'mimeType': mimeType,
    });
  }

  static Future<void> exportExcel({
    required String filename,
    required String title,
    required ExportData data,
  }) async {
    final workbook = xls.Excel.createExcel();
    final sheetName = workbook.getDefaultSheet()!;
    final sheet = workbook[sheetName];

    final headers = data.headers;
    final lastCol = headers.length - 1;

    xls.CellStyle bandStyle({required int size, required bool bold, bool italic = false}) => xls.CellStyle(
          bold: bold,
          italic: italic,
          fontSize: size,
          fontColorHex: xls.ExcelColor.fromHexString(_Brand.white),
          backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.hexAt(0.5)),
        );

    void mergedBandRow(int rowIndex, String text, {required int size, bool bold = true, bool italic = false}) {
      sheet.appendRow([xls.TextCellValue(text)]);
      sheet.merge(
        xls.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        xls.CellIndex.indexByColumnRow(columnIndex: lastCol, rowIndex: rowIndex),
      );
      sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle =
          bandStyle(size: size, bold: bold, italic: italic);
    }

    // Letterhead: site name, module (report) name, printed timestamp — one
    // merged, gradient-filled row each, matching the website's Excel header.
    final printedAt = DateFormat('dd MMM y, HH:mm').format(DateTime.now());
    mergedBandRow(0, _orgName, size: 14);
    mergedBandRow(1, title, size: 11);
    mergedBandRow(2, 'Printed: $printedAt', size: 9, bold: false, italic: true);

    sheet.appendRow([]); // spacer row

    // Column headers, gradient-swept left to right.
    final headerRow = 4;
    sheet.appendRow(headers.map((h) => xls.TextCellValue(h)).toList());
    for (var c = 0; c <= lastCol; c++) {
      sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: headerRow)).cellStyle = xls.CellStyle(
        bold: true,
        fontColorHex: xls.ExcelColor.fromHexString(_Brand.white),
        backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.hexAt((c + 0.5) / headers.length)),
      );
      sheet.setColumnWidth(c, 18);
    }

    for (final row in data.rows) {
      sheet.appendRow(row.map((v) => xls.TextCellValue(v)).toList());
    }

    if (data.totalRow != null) {
      final totalRowIndex = headerRow + 1 + data.rows.length;
      sheet.appendRow(data.totalRow!.map((v) => xls.TextCellValue(v)).toList());
      for (var c = 0; c <= lastCol; c++) {
        sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: totalRowIndex)).cellStyle = xls.CellStyle(
          bold: true,
          fontColorHex: xls.ExcelColor.fromHexString(_Brand.white),
          backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.hexAt((c + 0.5) / headers.length)),
        );
      }
    }

    sheet.appendRow([]); // spacer row
    final contactRowIndex = headerRow + 2 + data.rows.length + (data.totalRow != null ? 1 : 0);
    mergedBandRow(contactRowIndex, _contactLine, size: 9, bold: false);

    final bytes = workbook.save();
    if (bytes == null) return;
    await _saveToDownloads(
      '$filename.xlsx',
      bytes,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  static Future<void> exportPdf({
    required String filename,
    required String title,
    required ExportData data,
  }) async {
    final logoBytes = await rootBundle.load('assets/images/logo.jpeg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final printedAt = DateFormat('dd MMM y, HH:mm').format(DateTime.now());
    final headers = data.headers;
    final colCount = headers.length;

    pw.BoxDecoration bandDecoration() => pw.BoxDecoration(
          gradient: pw.LinearGradient(
            begin: pw.Alignment.centerLeft,
            end: pw.Alignment.centerRight,
            colors: [_Brand.gradientStart, _Brand.gradientEnd],
          ),
        );

    pw.Widget gradientCell(String text, int colIndex, {required bool bold}) {
      final tStart = colIndex / colCount;
      final tEnd = (colIndex + 1) / colCount;
      return pw.Container(
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            begin: pw.Alignment.centerLeft,
            end: pw.Alignment.centerRight,
            colors: [_Brand.colorAt(tStart), _Brand.colorAt(tEnd)],
          ),
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(color: PdfColors.white, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 8),
        ),
      );
    }

    final tableData = [...data.rows, if (data.totalRow != null) data.totalRow!];
    final totalRowNum = data.totalRow != null ? tableData.length - 1 : -1;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        header: (context) => pw.Container(
          width: double.infinity,
          decoration: bandDecoration(),
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, width: 28, height: 28),
              pw.SizedBox(height: 4),
              pw.Text(_orgName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.SizedBox(height: 2),
              pw.Text(
                '$title   •   Printed: $printedAt',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.white),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          width: double.infinity,
          decoration: bandDecoration(),
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          alignment: pw.Alignment.center,
          child: pw.Text(_contactLine, style: pw.TextStyle(fontSize: 8, color: PdfColors.white)),
        ),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: pw.Table(
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.TableRow(
                  children: [for (var c = 0; c < colCount; c++) gradientCell(headers[c], c, bold: true)],
                ),
                for (var r = 0; r < tableData.length; r++)
                  pw.TableRow(
                    // Matches jsPDF-autotable's default "striped" theme: odd
                    // body rows get a light grey fill, even ones stay plain.
                    decoration: r != totalRowNum && r.isOdd
                        ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF5F5F5))
                        : null,
                    children: [
                      for (var c = 0; c < colCount; c++)
                        r == totalRowNum
                            ? gradientCell(tableData[r][c], c, bold: true)
                            : pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                child: pw.Text(tableData[r][c], style: const pw.TextStyle(fontSize: 8)),
                              ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    await _saveToDownloads('$filename.pdf', bytes, 'application/pdf');
  }
}
