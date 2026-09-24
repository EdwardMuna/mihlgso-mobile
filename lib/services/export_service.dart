import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Brand colors, matching lib/core/theme/app_theme.dart's AppColors (kept
/// separate since this file has no Flutter widget dependency, only Dart/PDF
/// color types).
class _Brand {
  _Brand._();
  static const primary = PdfColor.fromInt(0xFF0E5A8A);
  static const accent = PdfColor.fromInt(0xFFE6A627);
  static const borderLight = PdfColor.fromInt(0xFFE2E8F0);
  static const zebra = PdfColor.fromInt(0xFFF8FAFC);

  static const primaryExcel = 'FF0E5A8A';
  static const zebraExcel = 'FFF1F5F9';
  static const white = 'FFFFFFFF';
}

/// Turns an admin list (Payments/Donations/Applications) into a branded CSV,
/// Excel, or PDF file and saves it straight to the device's real Downloads
/// folder — no share sheet, no save-location picker — via a native platform
/// channel (see android/.../MainActivity.kt: MediaStore.Downloads on
/// Android 10+, direct file write on 9 and below).
class ExportService {
  ExportService._();

  static const _channel = MethodChannel('mihlgso/downloads');
  static const _orgName = 'MIHLGSO';
  static const _orgFull = 'Mafia Island Higher Learning Graduates and Students Organization';

  static Future<void> _saveToDownloads(String name, List<int> bytes, String mimeType) async {
    await _channel.invokeMethod<String>('saveToDownloads', {
      'name': name,
      'bytes': Uint8List.fromList(bytes),
      'mimeType': mimeType,
    });
  }

  static Future<void> exportCsv({
    required String filename,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    // CSV has no styling capability at all, but a leading "# <org> — <title>"
    // comment line still marks the file as MIHLGSO's the moment it's opened,
    // and spreadsheet apps skip lines starting with '#' when re-imported.
    final generatedAt = DateFormat('d MMM yyyy, HH:mm').format(DateTime.now());
    final csv = const ListToCsvConverter().convert([headers, ...rows]);
    final withBanner = '# $_orgName — $title (generated $generatedAt)\n$csv';
    await _saveToDownloads('$filename.csv', withBanner.codeUnits, 'text/csv');
  }

  static Future<void> exportExcel({
    required String filename,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final workbook = xls.Excel.createExcel();
    final sheetName = workbook.getDefaultSheet()!;
    final sheet = workbook[sheetName];

    final lastCol = headers.length - 1;
    final titleStyle = xls.CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: xls.ExcelColor.fromHexString(_Brand.white),
      backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.primaryExcel),
    );
    final subtitleStyle = xls.CellStyle(
      italic: true,
      fontSize: 9,
      fontColorHex: xls.ExcelColor.fromHexString(_Brand.white),
      backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.primaryExcel),
    );
    final headerStyle = xls.CellStyle(
      bold: true,
      fontColorHex: xls.ExcelColor.fromHexString(_Brand.white),
      backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.primaryExcel),
    );
    final zebraStyle = xls.CellStyle(backgroundColorHex: xls.ExcelColor.fromHexString(_Brand.zebraExcel));

    // Row 0: org name (merged across every column).
    sheet.appendRow([xls.TextCellValue('$_orgName — $title')]);
    sheet.merge(
      xls.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      xls.CellIndex.indexByColumnRow(columnIndex: lastCol, rowIndex: 0),
    );
    sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = titleStyle;

    // Row 1: generated timestamp (merged too).
    final generatedAt = DateFormat('d MMM yyyy, HH:mm').format(DateTime.now());
    sheet.appendRow([xls.TextCellValue('Generated $generatedAt · $_orgFull')]);
    sheet.merge(
      xls.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      xls.CellIndex.indexByColumnRow(columnIndex: lastCol, rowIndex: 1),
    );
    sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = subtitleStyle;

    // Row 2: column headers.
    sheet.appendRow(headers.map((h) => xls.TextCellValue(h)).toList());
    for (var c = 0; c <= lastCol; c++) {
      sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 2)).cellStyle = headerStyle;
      sheet.setColumnWidth(c, 20);
    }

    // Data rows, zebra-striped for readability.
    for (var r = 0; r < rows.length; r++) {
      sheet.appendRow(rows[r].map((v) => xls.TextCellValue(v)).toList());
      if (r.isOdd) {
        for (var c = 0; c <= lastCol; c++) {
          sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 3)).cellStyle = zebraStyle;
        }
      }
    }

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
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final logoBytes = await rootBundle.load('assets/images/logo.jpeg');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final generatedAt = DateFormat('d MMM yyyy, HH:mm').format(DateTime.now());

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
        header: (context) {
          if (context.pageNumber > 1) return pw.SizedBox();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.ClipOval(child: pw.Image(logo, width: 40, height: 40, fit: pw.BoxFit.cover)),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(_orgName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _Brand.primary)),
                        pw.Text(_orgFull, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                  pw.Text(generatedAt, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(height: 2, color: _Brand.accent),
              pw.SizedBox(height: 10),
              pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _Brand.primary)),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: _Brand.borderLight, thickness: 0.5),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$_orgName — $title', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                ],
              ),
            ),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: _Brand.primary),
            oddRowDecoration: const pw.BoxDecoration(color: _Brand.zebra),
            border: pw.TableBorder.all(color: _Brand.borderLight, width: 0.5),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    await _saveToDownloads('$filename.pdf', bytes, 'application/pdf');
  }
}
