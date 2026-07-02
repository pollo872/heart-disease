import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heart_disease/features/dashboard/data/services/pdf_export_service.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.assessments,
    required this.userName,
  });

  final List<AssessmentUIModel> assessments;
  final String userName;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final GlobalKey _probabilityChartKey = GlobalKey();
  final GlobalKey _bmiChartKey = GlobalKey();
  final GlobalKey _bpChartKey = GlobalKey();

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

  List<AssessmentUIModel> get _sorted {
    final list = List<AssessmentUIModel>.from(widget.assessments);
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  double _toPercent(String prob) {
    final val = double.tryParse(prob) ?? 0.0;
    return val <= 1.0 ? val * 100 : val;
  }

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

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obese I';
    return 'Obese II+';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.riskMedium;
    if (bmi < 25) return AppColors.riskLow;
    if (bmi < 30) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  _TrendData _calcTrend(
    List<AssessmentUIModel> sorted,
    double Function(AssessmentUIModel) fn, {
    bool lowerIsBetter = true,
  }) {
    if (sorted.length < 2) return _TrendData(type: _TrendType.stable, delta: 0);
    final delta = fn(sorted.last) - fn(sorted.first);
    if (delta.abs() < 0.1) {
      return _TrendData(type: _TrendType.stable, delta: delta);
    }
    final improved = lowerIsBetter ? delta < 0 : delta > 0;
    return _TrendData(
        type: improved ? _TrendType.improved : _TrendType.worsened,
        delta: delta);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _shortDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.month}/${d.day}';
    } catch (_) {
      return iso.length >= 5 ? iso.substring(5, 10) : iso;
    }
  }

  String _longDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
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
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  // ── PDF Capture ───────────────────────────────────────────────────────────
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
    final probBytes = await _capture(_probabilityChartKey);
    final bmiBytes = await _capture(_bmiChartKey);
    final bpBytes = await _capture(_bpChartKey);

    await PdfExportService.exportHealthReport(
      userName: widget.userName,
      sortedAssessments: sorted,
      riskChartBytes: probBytes,
      bmiChartBytes: bmiBytes,
      bpChartBytes: bpBytes,
    );
  }

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
      body: !hasData
          ? _buildEmpty()
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Export PDF button ──────────────────────────
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
                            mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 12),

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
                    const SizedBox(height: 24),

                    // ── Blood Pressure Chart ───────────────────────
                    _SectionHeader(
                      title: 'Blood Pressure',
                      subtitle: 'Systolic / Diastolic over time (mmHg)',
                      iconColor: AppColors.riskHigh,
                    ),
                    const SizedBox(height: 10),
                    RepaintBoundary(
                      key: _bpChartKey,
                      child: _BloodPressureChart(sorted: sorted),
                    ),
                    const SizedBox(height: 24),

                    // ── Cholesterol & Blood Sugar tiles ───────────
                    _SectionHeader(
                      title: 'Lab Values',
                      subtitle: 'Latest cholesterol & blood sugar readings',
                      iconColor: const Color(0xFF7B1FA2),
                    ),
                    const SizedBox(height: 10),
                    _LabValuesRow(latest: latest),
                    const SizedBox(height: 24),

                    // ── Latest Assessment detail ───────────────────
                    _buildLatestDetail(latest),
                    const SizedBox(height: 24),

                    // ── AI Insights (cross-assessment) ─────────────
                    if (sorted.any((a) => a.aiAnalysis != null)) ...[
                      _buildAiInsights(sorted),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No assessments yet',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Complete your first assessment to see your dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
        ],
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
  Widget _buildTrendRow(
    _TrendData probTrend,
    _TrendData bmiTrend,
    List<AssessmentUIModel> sorted,
  ) {
    if (sorted.length < 2) return const SizedBox.shrink();

    Widget chip(_TrendData trend, String label) {
      final Color color;
      final IconData icon;
      switch (trend.type) {
        case _TrendType.improved:
          color = AppColors.riskLow;
          icon = Icons.trending_down_rounded;
          break;
        case _TrendType.worsened:
          color = AppColors.riskHigh;
          icon = Icons.trending_up_rounded;
          break;
        case _TrendType.stable:
          color = AppColors.riskMedium;
          icon = Icons.trending_flat_rounded;
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(
            probTrend,
            'Risk ${probTrend.type == _TrendType.improved ? "↓" : probTrend.type == _TrendType.worsened ? "↑" : "→"} ${probTrend.delta.abs().toStringAsFixed(1)}%'),
        chip(
            bmiTrend,
            'BMI ${bmiTrend.type == _TrendType.improved ? "↓" : bmiTrend.type == _TrendType.worsened ? "↑" : "→"} ${bmiTrend.delta.abs().toStringAsFixed(1)}'),
      ],
    );
  }

  // ── Latest Detail Card ────────────────────────────────────────────────────
  Widget _buildLatestDetail(AssessmentUIModel latest) {
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
              const Text('Latest Assessment',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: rBg, borderRadius: BorderRadius.circular(50)),
                child: Text(latest.riskLevel,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: rText)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_longDate(latest.createdAt),
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          _DetailRow(label: 'Result', value: latest.predictionResult),
          _DetailRow(
            label: 'Risk Probability',
            value: '${_toPercent(latest.probability).toStringAsFixed(2)}%',
          ),
          _DetailRow(
              label: 'BMI',
              value:
                  '${latest.bmi.toStringAsFixed(1)} — ${_bmiCategory(latest.bmi)}'),
          _DetailRow(
              label: 'Blood Pressure',
              value: '${latest.systolicBP}/${latest.diastolicBP} mmHg'),
          _DetailRow(
              label: 'Blood Sugar',
              value: '${latest.bloodSugar.toStringAsFixed(0)} mg/dL'),
          _DetailRow(
              label: 'Cholesterol',
              value: '${latest.cholesterol.toStringAsFixed(0)} mg/dL'),
          if (latest.riskHint.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: rBg, borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 16, color: rText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(latest.riskHint,
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13, color: rText)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── AI Insights ───────────────────────────────────────────────────────────
  Widget _buildAiInsights(List<AssessmentUIModel> sorted) {
    final withAI = sorted.where((a) => a.aiAnalysis != null).toList();
    if (withAI.isEmpty) return const SizedBox.shrink();

    final Map<String, int> rfCount = {};
    final Map<String, int> wsCount = {};
    final Map<String, int> recCount = {};

    for (final a in withAI) {
      for (final f in a.aiAnalysis!.riskFactors) {
        rfCount[f.toLowerCase().trim()] =
            (rfCount[f.toLowerCase().trim()] ?? 0) + 1;
      }

      for (final w in a.aiAnalysis!.warningSigns) {
        wsCount[w.toLowerCase().trim()] =
            (wsCount[w.toLowerCase().trim()] ?? 0) + 1;
      }

      for (final r in a.aiAnalysis!.recommendations) {
        recCount[r.toLowerCase().trim()] =
            (recCount[r.toLowerCase().trim()] ?? 0) + 1;
      }
    }

    final topRiskFactors = (rfCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .toList();
    final topWarningSigns = (wsCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(4)
        .toList();
    final topRecs = (recCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(4)
        .toList();

    final first = withAI.first.aiAnalysis!;
    final last = withAI.last.aiAnalysis!;
    final lastNormalized =
        last.riskFactors.map((r) => r.toLowerCase().trim()).toSet();
    final firstNormalized =
        first.riskFactors.map((r) => r.toLowerCase().trim()).toSet();

    final newRisks = last.riskFactors
        .where((r) => !firstNormalized.contains(r.toLowerCase().trim()))
        .toList();

    final resolvedRisks = first.riskFactors
        .where((r) => !lastNormalized.contains(r.toLowerCase().trim()))
        .toList();
    final totalAssessments = withAI.length;

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
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.insights_rounded,
                  size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Health Insights',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text('Based on all your assessments',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(50)),
              child: Text('$totalAssessments assessments',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 16),
          if (topRiskFactors.isNotEmpty) ...[
            _insightSectionTitle(Icons.warning_amber_rounded,
                const Color(0xFFE53935), 'Most Recurring Risk Factors'),
            const SizedBox(height: 8),
            ...topRiskFactors.map((e) => _insightBarRow(
                  label: e.key,
                  count: e.value,
                  total: totalAssessments,
                  color: e.value == totalAssessments
                      ? AppColors.riskHigh
                      : e.value >= totalAssessments / 2
                          ? AppColors.riskMedium
                          : AppColors.riskLow,
                )),
            const SizedBox(height: 12),
          ],
          if (topWarningSigns.isNotEmpty) ...[
            _insightSectionTitle(Icons.notifications_active_outlined,
                const Color(0xFFE65100), 'Persistent Warning Signs'),
            const SizedBox(height: 8),
            ...topWarningSigns.map((e) => _insightTagRow(
                label: e.key, count: e.value, color: const Color(0xFFE65100))),
            const SizedBox(height: 12),
          ],
          if (newRisks.isNotEmpty || resolvedRisks.isNotEmpty) ...[
            _insightSectionTitle(Icons.compare_arrows_rounded,
                AppColors.primary, 'Progress: First vs Latest'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resolvedRisks.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resolved',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32))),
                          const SizedBox(height: 6),
                          ...resolvedRisks.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $r',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF1B5E20))),
                              )),
                        ],
                      ),
                    ),
                  ),
                if (newRisks.isNotEmpty && resolvedRisks.isNotEmpty)
                  const SizedBox(width: 8),
                if (newRisks.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFF3F3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New Risks',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB71C1C))),
                          const SizedBox(height: 6),
                          ...newRisks.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $r',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFB71C1C))),
                              )),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (topRecs.isNotEmpty) ...[
            _insightSectionTitle(Icons.medical_services_outlined,
                AppColors.primary, 'Most Recommended Actions'),
            const SizedBox(height: 8),
            ...topRecs.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9)),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e.value.key,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _insightSectionTitle(IconData icon, Color color, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }

  Widget _insightBarRow(
      {required String label,
      required int count,
      required int total,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textPrimary))),
              Text('$count/$total',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 5,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightTagRow(
      {required String label, required int count, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text('${count}x',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Blood Pressure Chart ──────────────────────────────────────────────────────

class _BloodPressureChart extends StatelessWidget {
  final List<AssessmentUIModel> sorted;
  const _BloodPressureChart({required this.sorted});

  String _shortDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.month}/${d.day}';
    } catch (_) {
      return iso.length >= 5 ? iso.substring(5, 10) : iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final withBP =
        sorted.where((a) => a.systolicBP > 0 && a.diastolicBP > 0).toList();

    if (withBP.isEmpty) return const SizedBox.shrink(); // مفيش data خالص

    final systolicSpots = withBP
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.systolicBP.toDouble()))
        .toList();
    final diastolicSpots = withBP
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.diastolicBP.toDouble()))
        .toList();

    final allVals = withBP
        .expand((a) => [a.systolicBP.toDouble(), a.diastolicBP.toDouble()])
        .toList();
    final minVal = allVals.reduce((a, b) => a < b ? a : b);
    final maxVal = allVals.reduce((a, b) => a > b ? a : b);

    // ✅ minY و maxY بناءً على الـ data الفعلية
    final minY = (minVal - 15).clamp(0.0, 60.0);
    final maxY = maxVal + 20;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFFEF4444), label: 'Systolic'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFF3B82F6), label: 'Diastolic'),
              const Spacer(),
              // Normal reference badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Normal: <120/80',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.borderLight, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= withBP.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(_shortDate(withBP[idx].createdAt),
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                // Reference lines
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                        y: 120,
                        color: const Color(0xFFEF4444).withOpacity(0.4),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                        label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            labelResolver: (_) => '120',
                            style: const TextStyle(
                                fontSize: 9, color: Color(0xFFEF4444)))),
                    HorizontalLine(
                        y: 80,
                        color: const Color(0xFF3B82F6).withOpacity(0.4),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                        label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            labelResolver: (_) => '80',
                            style: const TextStyle(
                                fontSize: 9, color: Color(0xFF3B82F6)))),
                  ],
                ),
                lineBarsData: [
                  // Systolic
                  LineChartBarData(
                    spots: systolicSpots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFFEF4444),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: const Color(0xFFEF4444),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withOpacity(0.12),
                          const Color(0xFFEF4444).withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Diastolic
                  LineChartBarData(
                    spots: diastolicSpots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF3B82F6),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: const Color(0xFF3B82F6),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.08),
                          const Color(0xFF3B82F6).withOpacity(0.0)
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Lab Values Row (Cholesterol + Blood Sugar) ───────────────────────────────

class _LabValuesRow extends StatelessWidget {
  final AssessmentUIModel latest;
  const _LabValuesRow({required this.latest});

  _LabStatus _cholStatus() {
    if (latest.cholesterolLevel == 'Normal') return _LabStatus.normal;
    if (latest.cholesterolLevel == 'Elevated') return _LabStatus.borderline;
    return _LabStatus.high;
  }

  _LabStatus _sugarStatus() {
    if (latest.sugerLevel == 'Normal') return _LabStatus.normal;
    if (latest.sugerLevel == 'Elevated') return _LabStatus.borderline;
    return _LabStatus.high;
  }

  @override
  Widget build(BuildContext context) {
    final cholSt = _cholStatus();
    final sugSt = _sugarStatus();

    return Row(
      children: [
        Expanded(
            child: _LabTile(
          icon: Icons.science_outlined,
          label: 'Cholesterol',
          value: '${latest.cholesterol.toStringAsFixed(0)} mg/dL',
          reference: '< 200 normal',
          status: cholSt,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _LabTile(
          icon: Icons.bloodtype_outlined,
          label: 'Blood Sugar',
          value: '${latest.bloodSugar.toStringAsFixed(0)} mg/dL',
          reference: '< 100 normal',
          status: sugSt,
        )),
      ],
    );
  }
}

enum _LabStatus { normal, borderline, high }

extension _LabStatusExt on _LabStatus {
  Color get color => switch (this) {
        _LabStatus.normal => const Color(0xFF2E7D32),
        _LabStatus.borderline => const Color(0xFFF57C00),
        _LabStatus.high => const Color(0xFFC62828),
      };
  Color get bg => switch (this) {
        _LabStatus.normal => const Color(0xFFF1FFF3),
        _LabStatus.borderline => const Color(0xFFFFF8E1),
        _LabStatus.high => const Color(0xFFFFEBEE),
      };
  String get label => switch (this) {
        _LabStatus.normal => 'Normal',
        _LabStatus.borderline => 'Borderline',
        _LabStatus.high => 'High',
      };
}

class _LabTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String reference;
  final _LabStatus status;

  const _LabTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.reference,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: status.color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: status.color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: status.color)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status.label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: status.color)),
              ),
              const Spacer(),
              Text(reference,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color iconColor;

  const _SectionHeader(
      {required this.title, required this.subtitle, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final String? subtitle;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: color.withOpacity(0.7))),
          ],
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Line Chart Card (reusable) ───────────────────────────────────────────────

class _ReferenceLine {
  final double y;
  final String label;
  final Color color;
  const _ReferenceLine(
      {required this.y, required this.label, required this.color});
}

class _HighlightRange {
  final double minY;
  final double maxY;
  final Color color;
  final String label;
  const _HighlightRange(
      {required this.minY,
      required this.maxY,
      required this.color,
      required this.label});
}

class _LineChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final Color lineColor;
  final String unit;
  final double minY;
  final double maxY;
  final List<_ReferenceLine> referenceLines;
  final String tooltipSuffix;
  final _HighlightRange? highlightRange;

  const _LineChartCard({
    required this.spots,
    required this.labels,
    required this.lineColor,
    required this.unit,
    required this.minY,
    required this.maxY,
    this.referenceLines = const [],
    this.tooltipSuffix = '',
    this.highlightRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.borderLight, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: referenceLines
                      .map((r) => HorizontalLine(
                            y: r.y,
                            color: r.color.withOpacity(0.5),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              labelResolver: (_) => r.label,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: r.color,
                                  fontFamily: 'Inter'),
                            ),
                          ))
                      .toList(),
                ),
                rangeAnnotations: highlightRange != null
                    ? RangeAnnotations(
                        horizontalRangeAnnotations: [
                          HorizontalRangeAnnotation(
                            y1: highlightRange!.minY,
                            y2: highlightRange!.maxY,
                            color: highlightRange!.color.withOpacity(0.07),
                          ),
                        ],
                      )
                    : null,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (val, _) => Text(
                        '${val.toInt()}$unit',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: lineColor),
                              children: [
                                TextSpan(
                                  text: labels[idx],
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) {
                        Color dotColor = lineColor;
                        if (tooltipSuffix == '%') {
                          final v = spot.y;
                          if (v < 20) {
                            dotColor = AppColors.riskLow;
                          } else if (v < 50)
                            dotColor = AppColors.riskMedium;
                          else
                            dotColor = AppColors.riskHigh;
                        } else {
                          final v = spot.y;
                          if (v >= 18.5 && v < 25) {
                            dotColor = AppColors.riskLow;
                          } else if (v < 30)
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
                          lineColor.withOpacity(0.15),
                          lineColor.withOpacity(0.0)
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

// ─── BMI Info Panel ───────────────────────────────────────────────────────────

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
          const Text('BMI Guidelines (WHO)',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
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
            'BMI = weight(kg) ÷ height²(m)\nA BMI between 18.5–24.9 indicates a healthy weight.',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _BmiRow extends StatelessWidget {
  const _BmiRow(
      {required this.range,
      required this.label,
      required this.color,
      required this.icon});
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
                      color: AppColors.textPrimary))),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

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
                  color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
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
