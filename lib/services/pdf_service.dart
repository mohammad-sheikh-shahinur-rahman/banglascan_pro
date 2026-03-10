
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  /// Generates a professional PDF and shows a Print/Preview dialog
  Future<void> generateAndPrintPdf(String imagePath, String ocrText) async {
    final pdf = pw.Document();
    
    // Load font for Bengali support
    final fontData = await rootBundle.load("assets/fonts/HindSiliguri-Regular.ttf");
    final banglaFont = pw.Font.ttf(fontData);

    final image = pw.MemoryImage(File(imagePath).readAsBytesSync());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('BanglaScan Pro Report', 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                pw.Text(DateTime.now().toString().substring(0, 16), 
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            ),
            pw.Divider(thickness: 2, color: PdfColors.teal),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Container(
                height: 250,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text('Extracted Content:', 
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: banglaFont, color: PdfColors.teal)),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Text(ocrText, 
                style: pw.TextStyle(fontSize: 12, font: banglaFont, lineSpacing: 4)),
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Digitally Generated via BanglaScan Pro', 
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ),
          ];
        },
      ),
    );

    // Show professional print/preview dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'BanglaScan_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
