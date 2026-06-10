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

  static Future<void> exportHealthReport({
    required String userName,
    required List<AssessmentUIModel> sortedAssessments,
    Uint8List? riskChartBytes,
    Uint8List? bmiChartBytes,
    Uint8List? bpChartBytes,
  }) async {
    final pdf = pw.Document();
    final latest =
        sortedAssessments.isNotEmpty ? sortedAssessments.last : null;
    final now = DateTime.now().toLocal().toString().substring(0, 10);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        textDirection: pw.TextDirection.ltr,
        build: (ctx) => [
          // ── Header ──────────────────────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Health Status Report',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Patient: $userName',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Report Date: $now',
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
                    'HR',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white),
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
              'Latest Health Assessment Summary',
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
                    'Date',
                    latest.createdAt.length >= 10
                        ? latest.createdAt.substring(0, 10)
                        : latest.createdAt,
                  ),
                  _summaryCell(
                    'Blood Pressure',
                    '${latest.systolicBP}/${latest.diastolicBP} mmHg',
                  ),
                  _summaryCell(
                    'Blood Sugar',
                    '${latest.bloodSugar.toStringAsFixed(0)} mg/dL',
                  ),
                  _summaryCell(
                    'Cholesterol',
                    '${latest.cholesterol.toStringAsFixed(0)} mg/dL',
                  ),
                  _summaryCell(
                    'Risk %',
                    '${_riskPercent(latest.probability).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // ── Risk Chart ───────────────────────────────────────────────────
          if (riskChartBytes != null) ...[
            pw.Text(
              'Heart Disease Risk Trend',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(riskChartBytes), height: 170),
            pw.SizedBox(height: 20),
          ],

          // ── BMI Chart ────────────────────────────────────────────────────
          if (bmiChartBytes != null) ...[
            pw.Text(
              'BMI Over Time',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(bmiChartBytes), height: 170),
            pw.SizedBox(height: 20),
          ],

          // ── BP Chart ─────────────────────────────────────────────────────
          if (bpChartBytes != null) ...[
            pw.Text(
              'Blood Pressure Over Time',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(bpChartBytes), height: 170),
            pw.SizedBox(height: 20),
          ],

          // ── All Assessments Table ────────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),
          pw.Text(
            'All Assessments History (${sortedAssessments.length})',
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            // ✅ الجدول الجديد: التاريخ | ضغط الدم | السكر | الكوليسترول | نسبة الخطر
            headers: ['Date', 'Blood Pressure', 'Blood Sugar', 'Cholesterol', 'Risk %'],
            data: sortedAssessments.map((a) {
              final dateStr = a.createdAt.length >= 10
                  ? a.createdAt.substring(0, 10)
                  : a.createdAt;
              return [
                dateStr,
                '${a.systolicBP}/${a.diastolicBP} mmHg',
                '${a.bloodSugar.toStringAsFixed(0)} mg/dL',
                '${a.cholesterol.toStringAsFixed(0)} mg/dL',
                '${_riskPercent(a.probability).toStringAsFixed(1)}%',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColors.grey100),
          ),

          // ── AI Health Insights ───────────────────────────────────────────
          ..._buildAiInsights(sortedAssessments),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static List<pw.Widget> _buildAiInsights(
      List<AssessmentUIModel> sorted) {
    final withAI = sorted.where((a) => a.aiAnalysis != null).toList();
    if (withAI.isEmpty) return [];

    final Map<String, int> rfCount  = {};
    final Map<String, int> wsCount  = {};
    final Map<String, int> recCount = {};

    for (final a in withAI) {
      for (final f in a.aiAnalysis!.riskFactors)     rfCount[f]  = (rfCount[f]  ?? 0) + 1;
      for (final w in a.aiAnalysis!.warningSigns)    wsCount[w]  = (wsCount[w]  ?? 0) + 1;
      for (final r in a.aiAnalysis!.recommendations) recCount[r] = (recCount[r] ?? 0) + 1;
    }

    final topRF  = (rfCount.entries.toList()  ..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();
    final topWS  = (wsCount.entries.toList()  ..sort((a, b) => b.value.compareTo(a.value))).take(4).toList();
    final topRec = (recCount.entries.toList() ..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();

    final total         = withAI.length;
    final firstAI       = withAI.first.aiAnalysis!;
    final lastAI        = withAI.last.aiAnalysis!;
    final newRisks      = lastAI.riskFactors.where((r) => !firstAI.riskFactors.contains(r)).toList();
    final resolvedRisks = firstAI.riskFactors.where((r) => !lastAI.riskFactors.contains(r)).toList();

    pw.Widget sectionTitle(String t, {PdfColor color = PdfColors.grey800}) =>
        pw.Text(t, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color));

    pw.Widget bullet(String text, {String? badge, PdfColor textColor = PdfColors.grey800}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('- ', style: pw.TextStyle(fontSize: 10, color: textColor, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 10, color: textColor))),
              if (badge != null)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(badge,
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange900)),
                ),
            ],
          ),
        );

    return [
      pw.SizedBox(height: 24),
      pw.Divider(color: PdfColors.grey300),
      pw.SizedBox(height: 14),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('AI Health Insights',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text('Based on $total assessments',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.blue800)),
          ),
        ],
      ),
      pw.SizedBox(height: 14),

      if (topRF.isNotEmpty) ...[
        sectionTitle('Most Recurring Risk Factors', color: PdfColors.red800),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(color: PdfColors.red50, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(children: topRF.map((e) => bullet(e.key, badge: '${e.value}/$total', textColor: PdfColors.red900)).toList()),
        ),
        pw.SizedBox(height: 12),
      ],

      if (topWS.isNotEmpty) ...[
        sectionTitle('Persistent Warning Signs', color: PdfColors.orange800),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(color: PdfColors.orange50, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(children: topWS.map((e) => bullet(e.key, badge: '${e.value}x', textColor: PdfColors.orange900)).toList()),
        ),
        pw.SizedBox(height: 12),
      ],

      if (withAI.length >= 2 && (newRisks.isNotEmpty || resolvedRisks.isNotEmpty)) ...[
        sectionTitle('Progress: First vs Latest Assessment'),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (resolvedRisks.isNotEmpty)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(color: PdfColors.green50, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Resolved Risks', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      pw.SizedBox(height: 4),
                      ...resolvedRisks.map((r) => bullet(r, textColor: PdfColors.green900)),
                    ],
                  ),
                ),
              ),
            if (newRisks.isNotEmpty && resolvedRisks.isNotEmpty) pw.SizedBox(width: 10),
            if (newRisks.isNotEmpty)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(color: PdfColors.red50, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('New Risks', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                      pw.SizedBox(height: 4),
                      ...newRisks.map((r) => bullet(r, textColor: PdfColors.red900)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],

      if (topRec.isNotEmpty) ...[
        sectionTitle('Most Recommended Actions', color: PdfColors.blue800),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(
            children: topRec.asMap().entries.map((e) =>
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 16, height: 16,
                      decoration: pw.BoxDecoration(color: PdfColors.blue800, borderRadius: pw.BorderRadius.circular(8)),
                      child: pw.Center(
                        child: pw.Text('${e.key + 1}',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      ),
                    ),
                    pw.SizedBox(width: 7),
                    pw.Expanded(child: pw.Text(e.value.key, style: const pw.TextStyle(fontSize: 10))),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    ];
  }

  static double _riskPercent(String probability) {
    final val = double.tryParse(probability) ?? 0.0;
    return val <= 1.0 ? val * 100 : val;
  }

  static pw.Widget _summaryCell(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }
}