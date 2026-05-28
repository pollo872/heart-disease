import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.assessments, // state.assessments مباشرة
  });

  /// مباشرة من state.assessments — نفس اللي بيستخدمه HistoryCard
  final List<AssessmentUIModel> assessments;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // RepaintBoundary keys للـ PDF
  final GlobalKey _probabilityChartKey = GlobalKey();
  final GlobalKey _bmiChartKey = GlobalKey();
  // 🔜 final GlobalKey _bpChartKey = GlobalKey();

  // BMI info dialog
  bool _showBmiInfo = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Sorted تصاعدي بالتاريخ ────────────────────────────────────────────────
  List<AssessmentUIModel> get _sorted {
    final list = List<AssessmentUIModel>.from(widget.assessments);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  // ── probability String → double (0–100) ───────────────────────────────────
  double _toPercent(String prob) {
    final val = double.tryParse(prob) ?? 0.0;
    return val <= 1.0 ? val * 100 : val;
  }

  // ── Risk color من AppColors ───────────────────────────────────────────────
  Color _riskColor(String level) => switch (level.toLowerCase()) {
        'low' => AppColors.riskLow,
        'medium' => AppColors.riskMedium,
        _ => AppColors.riskHigh,
      };

  Color _riskBg(String level) => switch (level.toLowerCase()) {
        'low' => AppColors.riskLowBg,
        'medium' => AppColors.riskMediumBg,
        _ => AppColors.riskHighBg,
      };

  Color _riskText(String level) => switch (level.toLowerCase()) {
        'low' => AppColors.riskLowText,
        'medium' => AppColors.riskMediumText,
        _ => AppColors.riskHighText,
      };

  // ── BMI Category (WHO Standard) ───────────────────────────────────────────
  // Underweight: < 18.5
  // Normal:      18.5 – 24.9  ✅ مثالي
  // Overweight:  25 – 29.9    ⚠️ تحذير
  // Obese I:     30 – 34.9    ❌ خطر
  // Obese II+:   ≥ 35         ❌ خطر مرتفع
  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obese I';
    return 'Obese II+';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.riskMedium; // نحيف جداً
    if (bmi < 25) return AppColors.riskLow; // مثالي
    if (bmi < 30) return AppColors.riskMedium; // overweight
    return AppColors.riskHigh; // obese
  }

  // ── Trend detection ───────────────────────────────────────────────────────
  // lowerIsBetter=true → انخفاض = تحسن (زي probability)
  // lowerIsBetter=false → ارتفاع = تحسن
  _TrendData _calcTrend(
    List<AssessmentUIModel> sorted,
    double Function(AssessmentUIModel) fn, {
    bool lowerIsBetter = true,
  }) {
    if (sorted.length < 2) {
      return _TrendData(type: _TrendType.stable, delta: 0);
    }
    final delta = fn(sorted.last) - fn(sorted.first);
    if (delta.abs() < 0.1)
      return _TrendData(type: _TrendType.stable, delta: delta);
    final improved = lowerIsBetter ? delta < 0 : delta > 0;
    return _TrendData(
      type: improved ? _TrendType.improved : _TrendType.worsened,
      delta: delta,
    );
  }

  // ── PDF Export ────────────────────────────────────────────────────────────
  Future<Uint8List?> _capture(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _exportPdf() async {
    final sorted = _sorted;
    final latest = sorted.isNotEmpty ? sorted.last : null;
    final probBytes = await _capture(_probabilityChartKey);
    final bmiBytes = await _capture(_bmiChartKey);
    final now = DateTime.now().toLocal().toString().substring(0, 10);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          pw.Text('Heart Health Report',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('Date: $now',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 16),
          if (latest != null) ...[
            pw.Text('Latest Assessment',
                style:
                    pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfCell('Risk Score',
                      '${_toPercent(latest.probability).toStringAsFixed(1)}%'),
                  _pdfCell('BMI', latest.bmi.toStringAsFixed(1)),
                  _pdfCell('Level', latest.riskLevel),
                  _pdfCell('Result', latest.predictionResult),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],
          if (probBytes != null) ...[
            pw.Text('Heart Disease Risk Probability',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(probBytes), height: 160),
            pw.SizedBox(height: 16),
          ],
          if (bmiBytes != null) ...[
            pw.Text('BMI Over Time',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(bmiBytes), height: 160),
            pw.SizedBox(height: 20),
          ],
          pw.Divider(),
          pw.SizedBox(height: 12),
          pw.Text('All Assessments',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Date', 'Risk %', 'BMI', 'Level', 'Result'],
            data: sorted
                .map((a) => [
                      a.createdAt.length >= 10
                          ? a.createdAt.substring(0, 10)
                          : a.createdAt,
                      '${_toPercent(a.probability).toStringAsFixed(1)}%',
                      a.bmi.toStringAsFixed(1),
                      a.riskLevel,
                      a.predictionResult,
                    ])
                .toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 9),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static pw.Widget _pdfCell(String label, String value) => pw.Column(children: [
        pw.Text(value,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text(label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ]);

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    final hasData = sorted.isNotEmpty;
    final latest = hasData ? sorted.last : null;

    final probTrend = _calcTrend(sorted, (a) => _toPercent(a.probability));
    final bmiTrend = _calcTrend(sorted, (a) => a.bmi);

    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   backgroundColor: AppColors.background,
      //   elevation: 0,
      //   leading: BackButton(color: AppColors.textPrimary),
      //   title: const Text(
      //     'Health Dashboard',
      //     style: TextStyle(
      //       fontFamily: 'Inter',
      //       fontSize: 18,
      //       fontWeight: FontWeight.w500,
      //       color: AppColors.textPrimary,
      //     ),
      //   ),
      //   actions: [
      //     if (hasData)
      //       Padding(
      //         padding: const EdgeInsets.only(right: 16),
      //         child: GestureDetector(
      //           onTap: _exportPdf,
      //           child: Container(
      //             padding:
      //                 const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      //             decoration: BoxDecoration(
      //               color: AppColors.primaryLight,
      //               borderRadius: BorderRadius.circular(8),
      //             ),
      //             child: const Row(
      //               children: [
      //                 Icon(Icons.picture_as_pdf_rounded,
      //                     size: 15, color: AppColors.primary),
      //                 SizedBox(width: 5),
      //                 Text('Export PDF',
      //                     style: TextStyle(
      //                       fontFamily: 'Inter',
      //                       fontSize: 13,
      //                       fontWeight: FontWeight.w500,
      //                       color: AppColors.primary,
      //                     )),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //   ],
      // ),
      body: !hasData
          ? _buildEmpty()
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: _exportPdf,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  size: 15, color: AppColors.primary),
                              SizedBox(width: 5),
                              Text('Export PDF',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ── Summary cards ──────────────────────────────
                    _buildSummaryRow(latest!, sorted),
                    const SizedBox(height: 20),

                    // ── Trend chips ────────────────────────────────
                    _buildTrendRow(probTrend, bmiTrend, sorted),
                    const SizedBox(height: 24),

                    // ── Probability Chart ──────────────────────────
                    _SectionHeader(
                      title: 'Heart Disease Risk Probability',
                      subtitle: 'Lower is better — target below 20%',
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    RepaintBoundary(
                      key: _probabilityChartKey,
                      child: _LineChartCard(
                        spots: sorted
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(),
                                _toPercent(e.value.probability)))
                            .toList(),
                        labels:
                            sorted.map((a) => _shortDate(a.createdAt)).toList(),
                        lineColor: AppColors.primary,
                        unit: '%',
                        minY: 0,
                        maxY: 100,
                        referenceLines: const [
                          _ReferenceLine(
                              y: 20,
                              label: 'Low Risk',
                              color: Color(0xFF22C55E)),
                          _ReferenceLine(
                              y: 50,
                              label: 'Medium Risk',
                              color: Color(0xFFF59E0B)),
                          _ReferenceLine(
                              y: 75,
                              label: 'High Risk',
                              color: Color(0xFFEF4444)),
                        ],
                        tooltipSuffix: '%',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── BMI Chart ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _SectionHeader(
                            title: 'BMI Over Time',
                            subtitle: 'Body Mass Index — WHO guidelines',
                            iconColor: AppColors.riskMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showBmiInfo = !_showBmiInfo),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Icon(
                              _showBmiInfo
                                  ? Icons.info_rounded
                                  : Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // BMI Info Panel (انضغط على ℹ️)
                    if (_showBmiInfo) ...[
                      _BmiInfoPanel(),
                      const SizedBox(height: 10),
                    ],

                    RepaintBoundary(
                      key: _bmiChartKey,
                      child: _LineChartCard(
                        spots: sorted
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.bmi))
                            .toList(),
                        labels:
                            sorted.map((a) => _shortDate(a.createdAt)).toList(),
                        lineColor: AppColors.riskMedium,
                        unit: '',
                        minY: 10,
                        maxY: sorted
                                .map((a) => a.bmi)
                                .reduce((a, b) => a > b ? a : b) +
                            10,
                        referenceLines: const [
                          _ReferenceLine(
                              y: 18.5,
                              label: '< 18.5 Underweight',
                              color: Color(0xFFF59E0B)),
                          _ReferenceLine(
                              y: 25,
                              label: '25 Overweight',
                              color: Color(0xFFF59E0B)),
                          _ReferenceLine(
                              y: 30,
                              label: '30 Obese I',
                              color: Color(0xFFEF4444)),
                        ],
                        tooltipSuffix: ' BMI',
                        highlightRange: const _HighlightRange(
                          minY: 18.5,
                          maxY: 24.9,
                          color: Color(0xFF22C55E),
                          label: 'Healthy Range',
                        ),
                      ),
                    ),

                    // 🔜 Blood Pressure Chart (هتضيفه بعدين)
                    // const SizedBox(height: 24),
                    // _SectionHeader(title: 'Blood Pressure', ...),
                    // RepaintBoundary(key: _bpChartKey, child: _BloodPressureChart(...)),

                    const SizedBox(height: 24),

                    // ── Latest Assessment detail ───────────────────
                    _buildLatestDetail(latest),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Summary Row ───────────────────────────────────────────────────────────
  Widget _buildSummaryRow(
      AssessmentUIModel latest, List<AssessmentUIModel> sorted) {
    final percent = _toPercent(latest.probability);
    final rColor = _riskColor(latest.riskLevel);
    final rBg = _riskBg(latest.riskLevel);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.favorite_rounded,
            label: 'Risk Score',
            value: '${percent.toStringAsFixed(1)}%',
            color: rColor,
            bg: rBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.monitor_weight_outlined,
            label: 'BMI',
            value: latest.bmi.toStringAsFixed(1),
            color: _bmiColor(latest.bmi),
            bg: _bmiColor(latest.bmi).withOpacity(0.1),
            subtitle: _bmiCategory(latest.bmi),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.assignment_outlined,
            label: 'Assessments',
            value: '${sorted.length}',
            color: AppColors.primary,
            bg: AppColors.primaryLight,
          ),
        ),
      ],
    );
  }

  // ── Trend Row ─────────────────────────────────────────────────────────────
  Widget _buildTrendRow(_TrendData probTrend, _TrendData bmiTrend,
      List<AssessmentUIModel> sorted) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TrendChip(label: 'Heart Risk', trend: probTrend),
        _TrendChip(label: 'BMI', trend: bmiTrend),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            '${sorted.length} records',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Latest Assessment Detail Card ─────────────────────────────────────────
  Widget _buildLatestDetail(AssessmentUIModel latest) {
    // final rColor = _riskColor(latest.riskLevel);
    final rBg = _riskBg(latest.riskLevel);
    final rText = _riskText(latest.riskLevel);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Latest Assessment',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rBg,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  latest.riskLevel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _longDate(latest.createdAt),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Result', value: latest.predictionResult),
          _DetailRow(
            label: 'Risk Probability',
            value: '${_toPercent(latest.probability).toStringAsFixed(2)}%',
          ),
          _DetailRow(
            label: 'BMI',
            value:
                '${latest.bmi.toStringAsFixed(1)} — ${_bmiCategory(latest.bmi)}',
          ),
          if (latest.riskHint.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 16, color: rText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      latest.riskHint,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: rText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.health_and_safety_outlined,
              size: 56, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'No assessments yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Complete an assessment to see your\nhealth progress over time',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _shortDate(String iso) {
    try {
      return iso.length >= 10 ? iso.substring(5, 10) : iso;
    } catch (_) {
      return iso;
    }
  }

  String _longDate(String iso) {
    try {
      if (iso.length < 10) return iso;
      final dt = DateTime.parse(iso);
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });
  final String title;
  final String subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    this.subtitle,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              )),
          if (subtitle != null)
            Text(subtitle!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: AppColors.textSecondary,
                )),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary,
              )),
        ],
      ),
    );
  }
}

// ── Trend Chip ────────────────────────────────────────────────────────────────
class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.label, required this.trend});
  final String label;
  final _TrendData trend;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon, String text) =
        switch (trend.type) {
      _TrendType.improved => (
          AppColors.riskLowBg,
          AppColors.riskLowText,
          Icons.trending_down_rounded,
          '${trend.delta.abs().toStringAsFixed(1)} ↓',
        ),
      _TrendType.worsened => (
          AppColors.riskHighBg,
          AppColors.riskHighText,
          Icons.trending_up_rounded,
          '+${trend.delta.abs().toStringAsFixed(1)} ↑',
        ),
      _TrendType.stable => (
          AppColors.surface,
          AppColors.textSecondary,
          Icons.remove_rounded,
          'Stable',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            '$label: $text',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Line Chart Card ──────────────────────────────────────────────────
class _ReferenceLine {
  const _ReferenceLine({
    required this.y,
    required this.label,
    required this.color,
  });
  final double y;
  final String label;
  final Color color;
}

class _HighlightRange {
  const _HighlightRange({
    required this.minY,
    required this.maxY,
    required this.color,
    required this.label,
  });
  final double minY;
  final double maxY;
  final Color color;
  final String label;
}

class _LineChartCard extends StatefulWidget {
  const _LineChartCard({
    required this.spots,
    required this.labels,
    required this.lineColor,
    required this.unit,
    required this.minY,
    required this.maxY,
    required this.referenceLines,
    required this.tooltipSuffix,
    this.highlightRange,
  });

  final List<FlSpot> spots;
  final List<String> labels;
  final Color lineColor;
  final String unit;
  final double minY;
  final double maxY;
  final List<_ReferenceLine> referenceLines;
  final String tooltipSuffix;
  final _HighlightRange? highlightRange;

  @override
  State<_LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<_LineChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_LineChartCard old) {
    super.didUpdateWidget(old);
    if (old.spots.length != widget.spots.length) {
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reference lines كـ ExtraLinesData
    final horizontalLines = widget.referenceLines
        .map((r) => HorizontalLine(
              y: r.y,
              color: r.color.withOpacity(0.6),
              strokeWidth: 1,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (_) => r.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: r.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
        .toList();

    // Highlight range (الـ healthy zone في BMI)
    // List<BetweenBarsData> between = [];
    // if (widget.highlightRange != null) {
    //   // نضيف سطرين invisible للـ healthy range
    //   // (مستخدمين RangeAnnotation بدلاً منها)
    // }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: widget.lineColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
      child: Column(
        children: [
          // Healthy range legend
          if (widget.highlightRange != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.highlightRange!.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: widget.highlightRange!.color.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.highlightRange!.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: widget.highlightRange!.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            height: 200,
            child: widget.spots.isEmpty
                ? const Center(
                    child: Text('Not enough data',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textHint)))
                : LineChart(
                    LineChartData(
                      minY: widget.minY,
                      maxY: widget.maxY,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.borderLight,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData:
                          ExtraLinesData(horizontalLines: horizontalLines),
                      // Highlight healthy BMI range
                      rangeAnnotations: widget.highlightRange != null
                          ? RangeAnnotations(
                              horizontalRangeAnnotations: [
                                HorizontalRangeAnnotation(
                                  y1: widget.highlightRange!.minY,
                                  y2: widget.highlightRange!.maxY,
                                  color: widget.highlightRange!.color
                                      .withOpacity(0.08),
                                ),
                              ],
                            )
                          : null,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 46,
                            getTitlesWidget: (val, _) => Text(
                              '${val.toStringAsFixed(0)}${widget.unit}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32, // ← زود المساحة
                            interval: widget.spots.length > 6
                                ? (widget.spots.length / 4).ceilToDouble()
                                : 1,
                            getTitlesWidget: (val, meta) {
                              final i = val.toInt();
                              if (i < 0 || i >= widget.labels.length) {
                                return const SizedBox();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 6,
                                child: Transform.rotate(
                                  angle: -0.5, // ← ميل خفيف
                                  child: Text(
                                    widget.labels[i],
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipColor: (_) => AppColors.surface,
                          tooltipBorder:
                              const BorderSide(color: AppColors.borderLight),
                          getTooltipItems: (spots) => spots.map((s) {
                            final i = s.x.toInt();
                            final date = (i >= 0 && i < widget.labels.length)
                                ? widget.labels[i]
                                : '';
                            return LineTooltipItem(
                              '${s.y.toStringAsFixed(1)}${widget.tooltipSuffix}\n',
                              TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.lineColor,
                              ),
                              children: [
                                TextSpan(
                                  text: date,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: widget.lineColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) {
                              // لون النقطة بناءً على القيمة
                              Color dotColor = widget.lineColor;
                              if (widget.tooltipSuffix == '%') {
                                final v = spot.y;
                                if (v < 20)
                                  dotColor = AppColors.riskLow;
                                else if (v < 50)
                                  dotColor = AppColors.riskMedium;
                                else
                                  dotColor = AppColors.riskHigh;
                              } else {
                                // BMI
                                final v = spot.y;
                                if (v >= 18.5 && v < 25)
                                  dotColor = AppColors.riskLow;
                                else if (v < 30)
                                  dotColor = AppColors.riskMedium;
                                else
                                  dotColor = AppColors.riskHigh;
                              }
                              return FlDotCirclePainter(
                                radius: 4.5,
                                color: Colors.white,
                                strokeWidth: 2.5,
                                strokeColor: dotColor,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                widget.lineColor.withOpacity(0.15),
                                widget.lineColor.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── BMI Info Panel ────────────────────────────────────────────────────────────
class _BmiInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI Guidelines (WHO)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _BmiRow(
              range: '< 18.5',
              label: 'Underweight',
              color: AppColors.riskMedium,
              icon: Icons.arrow_downward_rounded),
          _BmiRow(
              range: '18.5 – 24.9',
              label: 'Normal ✅',
              color: AppColors.riskLow,
              icon: Icons.check_circle_outline_rounded),
          _BmiRow(
              range: '25 – 29.9',
              label: 'Overweight',
              color: AppColors.riskMedium,
              icon: Icons.warning_amber_rounded),
          _BmiRow(
              range: '30 – 34.9',
              label: 'Obese Class I',
              color: AppColors.riskHigh,
              icon: Icons.error_outline_rounded),
          _BmiRow(
              range: '≥ 35',
              label: 'Obese Class II+',
              color: AppColors.riskHigh,
              icon: Icons.dangerous_outlined),
          const SizedBox(height: 8),
          const Text(
            'BMI = weight(kg) ÷ height²(m)\nA BMI between 18.5–24.9 indicates a healthy weight. Values outside this range are associated with increased risk of heart disease, diabetes, and other conditions.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiRow extends StatelessWidget {
  const _BmiRow({
    required this.range,
    required this.label,
    required this.color,
    required this.icon,
  });
  final String range;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(range,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ),
          Text(label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              )),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TREND DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum _TrendType { improved, worsened, stable }

class _TrendData {
  const _TrendData({required this.type, required this.delta});
  final _TrendType type;
  final double delta;
}
