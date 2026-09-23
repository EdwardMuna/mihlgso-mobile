import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Turns an admin list (Payments/Donations/Applications) into a CSV, Excel,
/// or PDF file and hands it to the OS share sheet — the standard mobile
/// equivalent of a browser "download", since there's no fixed Downloads
/// folder to write into directly.
class ExportService {
  ExportService._();

  static Future<File> _writeToTemp(String filename, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> _share(File file, String subject) async {
    await Share.shareXFiles([XFile(file.path)], subject: subject);
  }

  static Future<void> exportCsv({
    required String filename,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final csv = const ListToCsvConverter().convert([headers, ...rows]);
    final file = await _writeToTemp('$filename.csv', csv.codeUnits);
    await _share(file, title);
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
    sheet.appendRow(headers.map((h) => xls.TextCellValue(h)).toList());
    for (final row in rows) {
      sheet.appendRow(row.map((v) => xls.TextCellValue(v)).toList());
    }
    final bytes = workbook.save();
    if (bytes == null) return;
    final file = await _writeToTemp('$filename.xlsx', bytes);
    await _share(file, title);
  }

  static Future<void> exportPdf({
    required String filename,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE2E8F0)),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 22,
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    final file = await _writeToTemp('$filename.pdf', bytes);
    await _share(file, title);
  }
}
