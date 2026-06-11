import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/path_strings.dart';
import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/main_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/find_doctor.dart';
import 'dart:math' as math;

import 'package:heart_disease/theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final double score;
  final int maxScore;
  final String createdAt;
  final AssessmentUIModel assessment;

  const ResultScreen({
    super.key,
    required this.score,
    this.maxScore = 100,
    required this.createdAt,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assessment Result'.tr(),
              style: const TextStyle(
                color: Color(0xFF1E63F3),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Your heart health assessment result'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────
              Text(
                'Your Heart Health Assessment'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${'Completed'.tr()} ${DateFormat('MMMM d, y').format(DateTime.parse(createdAt))}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ── Score Card ───────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: assessment.riskBadgeColor,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: assessment.riskBadgeColor, width: 1.5),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: 130,
                      height: 90,
                      child: CustomPaint(
                        painter: _CircleGaugePainter(
                          value: score / maxScore,
                          trackColor: const Color(0xFFE8F5EE),
                          fillColor: assessment.riskColor,
                        ),
                        child: Center(
                          child: Text(
                            '$score%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: assessment.riskColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      isEnglish
                          ? '${'RiskLevelFromBack.${assessment.riskLevel}'.tr()} ${'RiskLevel'.tr()}'
                          : '${'RiskLevel'.tr()} ${'RiskLevelFromBack.${assessment.riskLevel}'.tr()} ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: assessment.riskColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${'Your assessment shows'.tr()} ${'RiskLevelFromBack.${assessment.riskLevel}'.tr()} ${'risk for heart disease'.tr()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: assessment.riskColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Vitals Card (BP + Blood Sugar + Cholesterol) ──
              _VitalsCard(assessment: assessment),
              const SizedBox(height: 24),

              // ── Recommended Next Steps ───────────────────────
              Text(
                'Recommended Next Steps'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              _NextStepCard(
                title: 'Maintain Healthy Habits',
                subtitle: assessment.riskMessage,
                titleColor: assessment.riskColor,
                subtitleColor: assessment.riskColor,
                backgroundColor: assessment.riskBadgeColor,
              ),
              const SizedBox(height: 10),
              _NextStepCard(
                title: 'Monitor Your Heart Health',
                subtitle: 'Track your blood pressure'.tr(),
                titleColor: const Color(0xFF1C398E),
                subtitleColor: const Color(0xFF1447E6),
                backgroundColor: const Color(0xFFBEDBFF),
              ),
              const SizedBox(height: 10),
              _NextStepCard(
                title: 'Learn More',
                subtitle: 'Read educational articles'.tr(),
                titleColor: const Color(0xFF1C398E),
                subtitleColor: const Color(0xFF1447E6),
                backgroundColor: const Color(0xFFBEDBFF),
              ),
              const SizedBox(height: 24),

              // ── AI Analysis Section ──────────────────────────
              if (assessment.aiAnalysis != null) ...[
                _AiAnalysisSection(analysis: assessment.aiAnalysis!),
                const SizedBox(height: 24),
              ],

              // ── Find a Doctor Button ─────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: findDoctor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          Image.asset(
                            PathStrings.doctorIconPath,
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Find a Doctor Nearby'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── View History Button ──────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => MainBloc(
                              MainRepo(MainRemoteDataSource()),
                            )..add(MainTabChangedEvent(1)),
                            child: const MainScreen(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history,
                              color: Color(0xFF1A1A2E), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'View Assessment History'.tr(),
                            style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Vitals Card ─────────────────────────────────────────────────────────────

class _VitalsCard extends StatelessWidget {
  final AssessmentUIModel assessment;
  const _VitalsCard({required this.assessment});

  _VitalStatus _bpStatus() {
    // Normal: systolic < 120 AND diastolic < 80
    if (assessment.dPLevel == "Normal") return _VitalStatus.normal;

    // Elevated: systolic 120–129 AND diastolic < 80
    if (assessment.dPLevel == "Elevated") return _VitalStatus.elevated;

    // High Stage 1: systolic 130–139 OR diastolic 80–89
    if (assessment.dPLevel == "High") return _VitalStatus.high;

    // High Stage 2: systolic >= 140 OR diastolic >= 90
    return _VitalStatus.high;
  }

  _VitalStatus _sugarStatus() {
    if (assessment.sugerLevel == "Normal") return _VitalStatus.normal;

    // Elevated: systolic 120–129 AND diastolic < 80
    if (assessment.sugerLevel == "Elevated") return _VitalStatus.elevated;

    // High Stage 1: systolic 130–139 OR diastolic 80–89
    if (assessment.sugerLevel == "High") return _VitalStatus.high;
    return _VitalStatus.high; // diabetic range
  }

  _VitalStatus _cholesterolStatus() {
    if (assessment.cholesterolLevel == "Normal") return _VitalStatus.normal;

    // Elevated: systolic 120–129 AND diastolic < 80
    if (assessment.cholesterolLevel == "Elevated") return _VitalStatus.elevated;

    // High Stage 1: systolic 130–139 OR diastolic 80–89
    if (assessment.cholesterolLevel == "High") return _VitalStatus.high; // borderline
    return _VitalStatus.high; // high
  }

  @override
  Widget build(BuildContext context) {
    final bpStatus = _bpStatus();
    final sugarStatus = _sugarStatus();
    final cholStatus = _cholesterolStatus();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 16, color: Color(0xFF1E63F3)),
              SizedBox(width: 6),
              Text(
                'Vital Signs',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // BP row — full width
          _VitalRow(
            icon: Icons.water_drop_outlined,
            label: 'Blood Pressure',
            value: '${assessment.systolicBP}/${assessment.diastolicBP} mmHg',
            status: bpStatus,
          ),
          const SizedBox(height: 10),

          // Sugar + Cholesterol side by side
          Row(
            children: [
              Expanded(
                child: _VitalTile(
                  icon: Icons.bloodtype_outlined,
                  label: 'Blood Sugar',
                  value: '${assessment.bloodSugar.toStringAsFixed(0)} mg/dL',
                  status: sugarStatus,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalTile(
                  icon: Icons.science_outlined,
                  label: 'Cholesterol',
                  value: '${assessment.cholesterol.toStringAsFixed(0)} mg/dL',
                  status: cholStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _VitalStatus { normal, elevated, high }

extension _VitalStatusExt on _VitalStatus {
  Color get color => switch (this) {
        _VitalStatus.normal => AppColors.textGreen,
        _VitalStatus.elevated => const Color(0xFFF57C00),
        _VitalStatus.high => const Color(0xFFC62828),
      };

  Color get bg => switch (this) {
        _VitalStatus.normal => const Color(0xFFF1FFF3),
        _VitalStatus.elevated => const Color(0xFFFFF8E1),
        _VitalStatus.high => const Color(0xFFFFEBEE),
      };

  String get label => switch (this) {
        _VitalStatus.normal => 'Normal',
        _VitalStatus.elevated => 'Elevated', // مش High
        _VitalStatus.high => 'High',
      };
}

class _VitalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _VitalStatus status;

  const _VitalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: status.color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: status.color,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _VitalStatus status;

  const _VitalTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: status.color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI Analysis Section ──────────────────────────────────────────────────────

class _AiAnalysisSection extends StatelessWidget {
  final AiAnalysisUI analysis;
  const _AiAnalysisSection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Health Analysis',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.summarize_outlined,
                      size: 16, color: Color(0xFF1E63F3)),
                  SizedBox(width: 6),
                  Text('Summary',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E63F3))),
                ],
              ),
              const SizedBox(height: 8),
              Text(analysis.summary,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF444444), height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AnalysisListCard(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFE53935),
                title: 'Risk Factors',
                items: analysis.riskFactors,
                bgColor: const Color(0xFFFFF3F3),
                textColor: const Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalysisListCard(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF2E7D32),
                title: 'Positives',
                items: analysis.positiveFactors,
                bgColor: const Color(0xFFF1FFF3),
                textColor: const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _AnalysisListCard(
          icon: Icons.medical_services_outlined,
          iconColor: const Color(0xFF1E63F3),
          title: 'Recommendations',
          items: analysis.recommendations,
          bgColor: const Color(0xFFF0F4FF),
          textColor: const Color(0xFF1A237E),
        ),
        const SizedBox(height: 10),
        _AnalysisListCard(
          icon: Icons.self_improvement,
          iconColor: const Color(0xFF00796B),
          title: 'Lifestyle Tips',
          items: analysis.lifestyleTips,
          bgColor: const Color(0xFFF0FAFA),
          textColor: const Color(0xFF004D40),
        ),
        const SizedBox(height: 10),
        if (analysis.warningSigns.isNotEmpty)
          _AnalysisListCard(
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFFE65100),
            title: 'Warning Signs to Watch',
            items: analysis.warningSigns,
            bgColor: const Color(0xFFFFF8F0),
            textColor: const Color(0xFFBF360C),
          ),
        if (analysis.warningSigns.isNotEmpty) const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F0FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1BEE7)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF7B1FA2)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Follow-up',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF7B1FA2))),
                    const SizedBox(height: 4),
                    Text(analysis.followUp,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A148C),
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalysisListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;
  final Color bgColor;
  final Color textColor;

  const _AnalysisListCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: iconColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: textColor, fontSize: 13)),
                  Expanded(
                      child: Text(item,
                          style: TextStyle(
                              fontSize: 12, color: textColor, height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next Step Card ───────────────────────────────────────────────────────────

class _NextStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final Color backgroundColor;

  const _NextStepCard({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.tr(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor)),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 13, color: subtitleColor, height: 1.4)),
        ],
      ),
    );
  }
}

// ─── Circle Gauge Painter ─────────────────────────────────────────────────────

class _CircleGaugePainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final Color fillColor;

  _CircleGaugePainter(
      {required this.value, required this.trackColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final radius = size.width / 2 - strokeWidth / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
