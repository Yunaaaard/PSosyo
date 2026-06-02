import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LoanAgreementPdfService {
  Future<String> saveAgreementPdf({
    required String borrowerName,
    required List<Offset?> signaturePoints,
  }) async {
    final doc = pw.Document();
    final signatureBytes = await _buildSignatureImage(signaturePoints);
    final safeBorrowerName = borrowerName.trim().isEmpty
        ? 'Not provided'
        : borrowerName.trim();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'Psosyo Loan Agreement',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Borrower Name: $safeBorrowerName',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'By accepting this Agreement, the Borrower agrees to obtain a loan from Sosyo in the amount of PHP 10,000, subject to an interest rate of 5%, with a total payable amount of PHP 10,500, due on or before 30 days. The Borrower agrees to fully repay the loan, including any applicable interest and charges, within the agreed period using the available payment methods in the application.',
            style: const pw.TextStyle(fontSize: 12, lineSpacing: 3),
          ),
          pw.SizedBox(height: 26),
          pw.Text(
            'Psosyo Terms and Conditions',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Bullet(
            text:
                'You agree to borrow PHP 10,000 with an interest rate of 5%, for a total payable amount of PHP 10,500, due on or before 30 days.',
          ),
          pw.Bullet(
            text:
                'You agree that this digital agreement and your acceptance are legally binding.',
          ),
          pw.Bullet(
            text:
                'You agree to repay using the approved repayment channels listed in the app.',
          ),
          pw.SizedBox(height: 34),
          pw.Text(
            'Borrower Signature',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            height: 120,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: signatureBytes == null
                ? pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'No signature provided',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                  )
                : pw.Image(
                    pw.MemoryImage(signatureBytes),
                    fit: pw.BoxFit.contain,
                  ),
          ),
        ],
      ),
    );

    final outputDir = await _resolveOutputDirectory();
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final now = DateTime.now();
    final fileName =
        'Psosyo_Loan_Agreement_${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}.pdf';
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(await doc.save(), flush: true);

    return file.path;
  }

  Future<Directory> _resolveOutputDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }

    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
    return getApplicationDocumentsDirectory();
  }

  Future<Uint8List?> _buildSignatureImage(List<Offset?> points) async {
    final concrete = points.whereType<Offset>().toList(growable: false);
    if (concrete.isEmpty) return null;

    double minX = concrete.first.dx;
    double minY = concrete.first.dy;
    double maxX = concrete.first.dx;
    double maxY = concrete.first.dy;

    for (final point in concrete) {
      if (point.dx < minX) minX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy > maxY) maxY = point.dy;
    }

    final srcWidth = (maxX - minX).clamp(1.0, double.infinity);
    final srcHeight = (maxY - minY).clamp(1.0, double.infinity);
    const targetWidth = 900.0;
    const targetHeight = 260.0;
    const padding = 16.0;

    final scaleX = (targetWidth - (padding * 2)) / srcWidth;
    final scaleY = (targetHeight - (padding * 2)) / srcHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = const Color(0xFF2F333A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Offset? previous;
    for (final point in points) {
      if (point == null) {
        previous = null;
        continue;
      }

      final transformed = Offset(
        ((point.dx - minX) * scale) + padding,
        ((point.dy - minY) * scale) + padding,
      );

      if (previous != null) {
        canvas.drawLine(previous, transformed, paint);
      }
      previous = transformed;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(targetWidth.toInt(), targetHeight.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
