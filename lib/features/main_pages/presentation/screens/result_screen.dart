import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/main_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/find_doctor.dart';
import 'package:heart_disease/res/app_colors.dart';
import 'dart:math' as math;


class ResultScreen extends StatelessWidget {
  final double score;
  final int maxScore;
  // final String riskLevel;
  final String createdAt;
  final AssessmentUIModel assessment;
  // final String description;

  const ResultScreen({
    super.key,
    required this.score,
    this.maxScore = 100,
    // required this.riskLevel,
    required this.createdAt,
    required this.assessment,
    // this.description =
    //     'Your assessment shows a low risk for heart disease. Continue maintaining your healthy lifestyle habits.',
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
          children:  [
            Text(
              'Assessment Result'.tr(),
              style: TextStyle(
                color: Color(0xFF1E63F3),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Your heart health assessment result'.tr(),
              style: TextStyle(color: Colors.grey, fontSize: 11),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
               '${'Completed'.tr()} ${DateFormat('MMMM d, y').format(DateTime.parse(createdAt))}',
                style: TextStyle(fontSize: 13, color: Colors.grey),
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
                    // Arc gauge
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
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$score',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: assessment.riskColor,
                                  ),
                                ),
                                Text(
                                  '/ $maxScore',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                     isEnglish?  '${'RiskLevelFromBack.${assessment.riskLevel}'.tr()} ${'RiskLevel'.tr()}': '${'RiskLevel'.tr()} ${'RiskLevelFromBack.${assessment.riskLevel}'.tr()} ',
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
              const SizedBox(height: 24),

              // ── Recommended Next Steps ───────────────────────
               Text(
                'Recommended Next Steps'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              _NextStepCard(
                title: 'Maintain Healthy Habits',
                subtitle:
                    assessment.riskMessage,
                titleColor: assessment.riskColor,
                subtitleColor: assessment.riskColor,
                backgroundColor: assessment.riskBadgeColor,
              ),
              const SizedBox(height: 10),
              _NextStepCard(
                title: 'Monitor Your Heart Health',
                subtitle:
                    'Track your blood pressure'.tr(),
                titleColor: Color(0xFF1C398E),
                subtitleColor: Color(0xFF1447E6),
                backgroundColor: Color(0xFFBEDBFF),
              ),
              const SizedBox(height: 10),
              _NextStepCard(
                title: 'Learn More',
                subtitle:
                    'Read educational articles'.tr(),
                titleColor: Color(0xFF1C398E),
                subtitleColor: Color(0xFF1447E6),
                backgroundColor: Color(0xFFBEDBFF),
              ),
              const SizedBox(height: 24),

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
                        children:  [
                          Icon(Icons.medical_services_outlined,
                              color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Find a Doctor Nearby'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward,
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
                            MainRepo(
                              MainRemoteDataSource(),
                            ),
                          )..add(MainTabChangedEvent(1)),
                          child: const MainScreen(),
                        ),
                      ),
                    );
                      // final bloc = context.read<MainBloc>();
                      // bloc.add(MainTabChangedEvent(1));
                      // Navigator.of(context).popUntil((route) => route.isFirst);
                      // bloc.add(GetProfileEvent());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:  [
                          Icon(Icons.history,
                              color: Color(0xFF1A1A2E), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'View Assessment History'.tr(),
                            style: TextStyle(
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

// ─── Next Step Card ───────────────────────────────────────────────────────────

class _NextStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final Color backgroundColor;

  const _NextStepCard(
      {required this.title,
      required this.subtitle,
      required this.titleColor,
      required this.subtitleColor,
      required this.backgroundColor});

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
          Text(
            title.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Circle Gauge Painter ────────────────────────────────────────────────────────

class _CircleGaugePainter extends CustomPainter {
  final double value; // 0.0 → 1.0
  final Color trackColor;
  final Color fillColor;

  _CircleGaugePainter({
    required this.value,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final radius = size.width / 2 - strokeWidth / 2;

    // Track (full circle)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Fill arc (starts from top, goes clockwise)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start from top
      2 * math.pi * value, // sweep clockwise
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
