// lib/features/dashboard/data/services/pdf_export_service.dart

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  /// Captures a [RenderRepaintBoundary] as PNG bytes.
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('PdfExportService.captureWidget error: $e');
      return null;
    }
  }

  /// Builds and opens the print/share dialog for the health report PDF.
  ///
  /// ✅ يستخدم فقط الـ fields الموجودة في AssessmentModelDashboard:
  ///    predictionResult, riskLevel, probability, createdAt
  ///
  /// 🔜 لما تضيف weight و BP بعدين:
  ///    1. أضف الـ fields في AssessmentModelDashboard
  ///    2. فك التعليق عن الأجزاء المعلّقة أسفل
  static Future<void> exportHealthReport({
    required String userName,
    required List<AssessmentUIModel> sortedAssessments,
    Uint8List? riskChartBytes,
    // 🔜 فك التعليق لما تضيف weight و BP:
    // Uint8List? weightChartBytes,
    // Uint8List? bpChartBytes,
  }) async {
    final pdf = pw.Document();
    final latest =
        sortedAssessments.isNotEmpty ? sortedAssessments.last : null;
    final now = DateTime.now().toLocal().toString().substring(0, 10);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => [
          // ── Header ──────────────────────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'تقرير الحالة الصحية',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'المريض: $userName',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'تاريخ التقرير: $now',
                    style: pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.Container(
                width: 48,
                height: 48,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Center(
                  child: pw.Text(
                    '❤',
                    style: const pw.TextStyle(
                        fontSize: 24, color: PdfColors.white),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 16),

          // ── Latest Reading Summary ───────────────────────────────────────
          if (latest != null) ...[
            pw.Text(
              'آخر قراءة صحية',
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _summaryCell(
                    'نسبة الخطر',
                    '${_riskPercent(latest.probability).toStringAsFixed(1)}%',
                  ),
                  _summaryCell('مستوى الخطر', latest.riskLevel),
                  _summaryCell('النتيجة', latest.predictionResult),
                  // 🔜 فك التعليق لما تضيف weight:
                  // _summaryCell('الوزن', '${latest.weight.toStringAsFixed(1)} كجم'),
                  // 🔜 فك التعليق لما تضيف BP:
                  // _summaryCell('ضغط الدم', '${latest.systolicBP}/${latest.diastolicBP} mmHg'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // ── Risk Chart ───────────────────────────────────────────────────
          if (riskChartBytes != null) ...[
            pw.Text(
              'نسبة خطر أمراض القلب',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(riskChartBytes), height: 170),
            pw.SizedBox(height: 20),
          ],

          // 🔜 فك التعليق لما تضيف weight chart:
          // if (weightChartBytes != null) ...[
          //   pw.Text('تطور الوزن', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          //   pw.SizedBox(height: 8),
          //   pw.Image(pw.MemoryImage(weightChartBytes), height: 170),
          //   pw.SizedBox(height: 16),
          // ],

          // 🔜 فك التعليق لما تضيف BP chart:
          // if (bpChartBytes != null) ...[
          //   pw.Text('تغير ضغط الدم', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          //   pw.SizedBox(height: 8),
          //   pw.Image(pw.MemoryImage(bpChartBytes), height: 170),
          //   pw.SizedBox(height: 16),
          // ],

          // ── All Assessments Table ────────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),
          pw.Text(
            'جميع الفحوصات (${sortedAssessments.length})',
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['التاريخ', 'نسبة الخطر', 'مستوى الخطر', 'النتيجة'],
            // 🔜 لما تضيف weight و BP:
            // headers: ['التاريخ', 'الوزن', 'ضغط الدم', 'نسبة الخطر', 'المستوى'],
            data: sortedAssessments.map((a) {
              final dateStr = a.createdAt.length >= 10
                  ? a.createdAt.substring(0, 10)
                  : a.createdAt;
              return [
                dateStr,
                '${_riskPercent(a.probability).toStringAsFixed(1)}%',
                a.riskLevel,
                a.predictionResult,
                // 🔜 لما تضيف weight و BP:
                // '${a.weight.toStringAsFixed(1)} كجم',
                // '${a.systolicBP}/${a.diastolicBP}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.white,
            ),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
            },
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColors.grey100),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// يحوّل الـ probability String لـ double بين 0–100
  /// يشتغل سواء كانت "0.75" أو "75" أو "75.0"
  static double _riskPercent(String probability) {
    final val = double.tryParse(probability) ?? 0.0;
    // لو القيمة بين 0 و 1 → اضربها في 100
    return val <= 1.0 ? val * 100 : val;
  }

  static pw.Widget _summaryCell(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
