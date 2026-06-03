// lib/features/dashboard/data/services/pdf_export_service.dart

// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class PdfExportService {
//   /// Captures a [RenderRepaintBoundary] as PNG bytes.
//   static Future<Uint8List?> captureWidget(GlobalKey key) async {
//     try {
//       final boundary =
//           key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) return null;
//       final image = await boundary.toImage(pixelRatio: 2.5);
//       final byteData =
//           await image.toByteData(format: ui.ImageByteFormat.png);
//       return byteData?.buffer.asUint8List();
//     } catch (e) {
//       debugPrint('PdfExportService.captureWidget error: $e');
//       return null;
//     }
//   }

//   /// Builds and opens the print/share dialog for the health report PDF.
//   ///
//   /// ✅ يستخدم فقط الـ fields الموجودة في AssessmentModelDashboard:
//   ///    predictionResult, riskLevel, probability, createdAt
//   ///
//   /// 🔜 لما تضيف weight و BP بعدين:
//   ///    1. أضف الـ fields في AssessmentModelDashboard
//   ///    2. فك التعليق عن الأجزاء المعلّقة أسفل
//   static Future<void> exportHealthReport({
//     required String userName,
//     required List<AssessmentUIModel> sortedAssessments,
//     Uint8List? riskChartBytes,
//     // 🔜 فك التعليق لما تضيف weight و BP:
//     // Uint8List? weightChartBytes,
//     // Uint8List? bpChartBytes,
//   }) async {
//     final pdf = pw.Document();
//     final latest =
//         sortedAssessments.isNotEmpty ? sortedAssessments.last : null;
//     final now = DateTime.now().toLocal().toString().substring(0, 10);

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(36),
//         textDirection: pw.TextDirection.rtl,
//         build: (ctx) => [
//           // ── Header ──────────────────────────────────────────────────────
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'تقرير الحالة الصحية',
//                     style: pw.TextStyle(
//                         fontSize: 22, fontWeight: pw.FontWeight.bold),
//                   ),
//                   pw.SizedBox(height: 4),
//                   pw.Text(
//                     'المريض: $userName',
//                     style: const pw.TextStyle(fontSize: 14),
//                   ),
//                   pw.Text(
//                     'تاريخ التقرير: $now',
//                     style: pw.TextStyle(
//                         fontSize: 12, color: PdfColors.grey600),
//                   ),
//                 ],
//               ),
//               pw.Container(
//                 width: 48,
//                 height: 48,
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.blue800,
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Center(
//                   child: pw.Text(
//                     '❤',
//                     style: const pw.TextStyle(
//                         fontSize: 24, color: PdfColors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 12),
//           pw.Divider(color: PdfColors.grey300),
//           pw.SizedBox(height: 16),

//           // ── Latest Reading Summary ───────────────────────────────────────
//           if (latest != null) ...[
//             pw.Text(
//               'آخر قراءة صحية',
//               style: pw.TextStyle(
//                   fontSize: 16, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 10),
//             pw.Container(
//               padding: const pw.EdgeInsets.all(14),
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.grey100,
//                 borderRadius: pw.BorderRadius.circular(10),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                 children: [
//                   _summaryCell(
//                     'نسبة الخطر',
//                     '${_riskPercent(latest.probability).toStringAsFixed(1)}%',
//                   ),
//                   _summaryCell('مستوى الخطر', latest.riskLevel),
//                   _summaryCell('النتيجة', latest.predictionResult),
//                   // 🔜 فك التعليق لما تضيف weight:
//                   // _summaryCell('الوزن', '${latest.weight.toStringAsFixed(1)} كجم'),
//                   // 🔜 فك التعليق لما تضيف BP:
//                   // _summaryCell('ضغط الدم', '${latest.systolicBP}/${latest.diastolicBP} mmHg'),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 20),
//           ],

//           // ── Risk Chart ───────────────────────────────────────────────────
//           if (riskChartBytes != null) ...[
//             pw.Text(
//               'نسبة خطر أمراض القلب',
//               style: pw.TextStyle(
//                   fontSize: 14, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 8),
//             pw.Image(pw.MemoryImage(riskChartBytes), height: 170),
//             pw.SizedBox(height: 20),
//           ],

//           // 🔜 فك التعليق لما تضيف weight chart:
//           // if (weightChartBytes != null) ...[
//           //   pw.Text('تطور الوزن', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//           //   pw.SizedBox(height: 8),
//           //   pw.Image(pw.MemoryImage(weightChartBytes), height: 170),
//           //   pw.SizedBox(height: 16),
//           // ],

//           // 🔜 فك التعليق لما تضيف BP chart:
//           // if (bpChartBytes != null) ...[
//           //   pw.Text('تغير ضغط الدم', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//           //   pw.SizedBox(height: 8),
//           //   pw.Image(pw.MemoryImage(bpChartBytes), height: 170),
//           //   pw.SizedBox(height: 16),
//           // ],

//           // ── All Assessments Table ────────────────────────────────────────
//           pw.Divider(color: PdfColors.grey300),
//           pw.SizedBox(height: 12),
//           pw.Text(
//             'جميع الفحوصات (${sortedAssessments.length})',
//             style: pw.TextStyle(
//                 fontSize: 14, fontWeight: pw.FontWeight.bold),
//           ),
//           pw.SizedBox(height: 8),
//           pw.Table.fromTextArray(
//             headers: ['التاريخ', 'نسبة الخطر', 'مستوى الخطر', 'النتيجة'],
//             // 🔜 لما تضيف weight و BP:
//             // headers: ['التاريخ', 'الوزن', 'ضغط الدم', 'نسبة الخطر', 'المستوى'],
//             data: sortedAssessments.map((a) {
//               final dateStr = a.createdAt.length >= 10
//                   ? a.createdAt.substring(0, 10)
//                   : a.createdAt;
//               return [
//                 dateStr,
//                 '${_riskPercent(a.probability).toStringAsFixed(1)}%',
//                 a.riskLevel,
//                 a.predictionResult,
//                 // 🔜 لما تضيف weight و BP:
//                 // '${a.weight.toStringAsFixed(1)} كجم',
//                 // '${a.systolicBP}/${a.diastolicBP}',
//               ];
//             }).toList(),
//             headerStyle: pw.TextStyle(
//               fontWeight: pw.FontWeight.bold,
//               fontSize: 11,
//               color: PdfColors.white,
//             ),
//             headerDecoration:
//                 const pw.BoxDecoration(color: PdfColors.blue800),
//             cellStyle: const pw.TextStyle(fontSize: 10),
//             cellAlignments: {
//               0: pw.Alignment.center,
//               1: pw.Alignment.center,
//               2: pw.Alignment.center,
//               3: pw.Alignment.center,
//             },
//             oddRowDecoration:
//                 const pw.BoxDecoration(color: PdfColors.grey100),
//           ),
//         ],
//       ),
//     );

//     await Printing.layoutPdf(onLayout: (_) async => pdf.save());
//   }

//   // ── Helpers ────────────────────────────────────────────────────────────────

//   /// يحوّل الـ probability String لـ double بين 0–100
//   /// يشتغل سواء كانت "0.75" أو "75" أو "75.0"
//   static double _riskPercent(String probability) {
//     final val = double.tryParse(probability) ?? 0.0;
//     // لو القيمة بين 0 و 1 → اضربها في 100
//     return val <= 1.0 ? val * 100 : val;
//   }

//   static pw.Widget _summaryCell(String label, String value) {
//     return pw.Column(
//       children: [
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//               fontSize: 14, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           label,
//           style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
//         ),
//       ],
//     );
//   }
// }


// lib/features/dashboard/data/services/pdf_export_service.dart

// lib/features/dashboard/data/services/pdf_export_service.dart

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
  /// ✅ Uses fields from AssessmentModelDashboard:
  ///    predictionResult, riskLevel, probability, createdAt
  ///
  /// 🔜 When adding weight and BP later:
  ///    1. Add the fields in AssessmentModelDashboard
  ///    2. Uncomment the commented blocks below
  static Future<void> exportHealthReport({
    required String userName,
    required List<AssessmentUIModel> sortedAssessments,
    Uint8List? riskChartBytes,
    Uint8List? bmiChartBytes,
    // 🔜 Uncomment when adding weight and BP:
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
                    'Risk Percentage',
                    '${_riskPercent(latest.probability).toStringAsFixed(1)}%',
                  ),
                  _summaryCell('Risk Level', latest.riskLevel),
                  _summaryCell('Result', latest.predictionResult),
                  // 🔜 Uncomment when adding weight:
                  // _summaryCell('Weight', '${latest.weight.toStringAsFixed(1)} kg'),
                  // 🔜 Uncomment when adding BP:
                  // _summaryCell('Blood Pressure', '${latest.systolicBP}/${latest.diastolicBP} mmHg'),
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

          // 🔜 Uncomment when adding weight chart:
          // if (weightChartBytes != null) ...[
          //   pw.Text('Weight Progress', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          //   pw.SizedBox(height: 8),
          //   pw.Image(pw.MemoryImage(weightChartBytes), height: 170),
          //   pw.SizedBox(height: 16),
          // ],

          // 🔜 Uncomment when adding BP chart:
          // if (bpChartBytes != null) ...[
          //   pw.Text('Blood Pressure Changes', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          //   pw.SizedBox(height: 8),
          //   pw.Image(pw.MemoryImage(bpChartBytes), height: 170),
          //   pw.SizedBox(height: 16),
          // ],

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
            headers: ['Date', 'Risk %', 'Risk Level', 'Result'],
            // 🔜 When adding weight and BP:
            // headers: ['Date', 'Weight', 'Blood Pressure', 'Risk %', 'Level'],
            data: sortedAssessments.map((a) {
              final dateStr = a.createdAt.length >= 10
                  ? a.createdAt.substring(0, 10)
                  : a.createdAt;
              return [
                dateStr,
                '${_riskPercent(a.probability).toStringAsFixed(1)}%',
                a.riskLevel,
                a.predictionResult,
                // 🔜 When adding weight and BP:
                // '${a.weight.toStringAsFixed(1)} kg',
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
      for (final f in a.aiAnalysis!.riskFactors)    rfCount[f]  = (rfCount[f]  ?? 0) + 1;
      for (final w in a.aiAnalysis!.warningSigns)   wsCount[w]  = (wsCount[w]  ?? 0) + 1;
      for (final r in a.aiAnalysis!.recommendations) recCount[r] = (recCount[r] ?? 0) + 1;
    }

    final topRF  = (rfCount.entries.toList() ..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();
    final topWS  = (wsCount.entries.toList() ..sort((a, b) => b.value.compareTo(a.value))).take(4).toList();
    final topRec = (recCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();

    final total         = withAI.length;
    final firstAI       = withAI.first.aiAnalysis!;
    final lastAI        = withAI.last.aiAnalysis!;
    final newRisks      = lastAI.riskFactors.where((r) => !firstAI.riskFactors.contains(r)).toList();
    final resolvedRisks = firstAI.riskFactors.where((r) => !lastAI.riskFactors.contains(r)).toList();

    // ── Helpers (تم استبدال الـ Bullet بـ شرطة عادية آمنة للـ Font) ─────────────────────────────
    pw.Widget sectionTitle(String t, {PdfColor color = PdfColors.grey800}) =>
        pw.Text(t,
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: color));

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

      // Header
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

      // ── Most Recurring Risk Factors ────────────────────────────────────
      if (topRF.isNotEmpty) ...[
        sectionTitle('Most Recurring Risk Factors', color: PdfColors.red800),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.red50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: topRF
                .map((e) => bullet(e.key,
                    badge: '${e.value}/$total',
                    textColor: PdfColors.red900))
                .toList(),
          ),
        ),
        pw.SizedBox(height: 12),
      ],

      // ── Persistent Warning Signs ───────────────────────────────────────
      if (topWS.isNotEmpty) ...[
        sectionTitle('Persistent Warning Signs', color: PdfColors.orange800),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: topWS
                .map((e) => bullet(e.key,
                    badge: '${e.value}x',
                    textColor: PdfColors.orange900))
                .toList(),
          ),
        ),
        pw.SizedBox(height: 12),
      ],

      // ── First vs Latest (تم استبدال الرموز النصية بـ كلمات واضحة) ───────────────────────
      if (withAI.length >= 2 &&
          (newRisks.isNotEmpty || resolvedRisks.isNotEmpty)) ...[
        sectionTitle('Progress: First vs Latest Assessment'),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (resolvedRisks.isNotEmpty)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Resolved Risks', // شيلنا علامة الصح الكراش
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800)),
                      pw.SizedBox(height: 4),
                      ...resolvedRisks.map((r) => bullet(r, textColor: PdfColors.green900)),
                    ],
                  ),
                ),
              ),
            if (newRisks.isNotEmpty && resolvedRisks.isNotEmpty)
              pw.SizedBox(width: 10),
            if (newRisks.isNotEmpty)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('New Risks', // شيلنا السهم الكراش
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800)),
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

      // ── Top Recommendations ────────────────────────────────────────────
      if (topRec.isNotEmpty) ...[
        sectionTitle('Most Recommended Actions', color: PdfColors.blue800),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: topRec.asMap().entries.map((e) =>
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 16, height: 16,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue800,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Center(
                        child: pw.Text('${e.key + 1}',
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white)),
                      ),
                    ),
                    pw.SizedBox(width: 7),
                    pw.Expanded(
                        child: pw.Text(e.value.key,
                            style: const pw.TextStyle(fontSize: 10))),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    ];
  } // ── Helpers ────────────────────────────────────────────────────────────────

  /// Converts probability String to a double value between 0–100
  /// Works whether values are "0.75", "75", or "75.0"
  static double _riskPercent(String probability) {
    final val = double.tryParse(probability) ?? 0.0;
    // If the value is between 0 and 1 → multiply by 100
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