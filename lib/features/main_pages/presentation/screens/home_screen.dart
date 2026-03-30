import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/history_card.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/history_header.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/home_screen_header.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileErrorState) {
          return Center(child: Text(state.error));
        }

        if (state is ProfileSuccessState) {
          return _HomeContent(state: state);
        }

        return const SizedBox();
      },
    );
  }
}

///------------------------------------------------------------
/// MAIN CONTENT
///------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  final ProfileSuccessState state;

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final patient = state.patient;
    final assessment = state.assessment;

    final userName = "${patient.firstName} ${patient.lastName}";
    final hasAssessment = assessment != null;

    final probability = hasAssessment
        ? "${(assessment.probability * 100).toStringAsFixed(2)}%"
        : "";

    final predictionResult = assessment?.predictionResult ?? "";
    final riskLevel = assessment?.riskLevel ?? "";
    final createdAt = assessment?.createdAt ?? "";

    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeaderSection(
              userName: userName,
              hasAssessment: hasAssessment,
              predictionResult: predictionResult,
              riskLevel: riskLevel,
              probability: probability,
              createdAt: createdAt,
            ),
            _BodySection(
              state: state,
              hasAssessment: hasAssessment,
              predictionResult: predictionResult,
              riskLevel: riskLevel,
              probability: probability,
              createdAt: createdAt,
            )
          ],
        ),
      ),
    );
  }
}

///------------------------------------------------------------
/// HEADER + LATEST CARD
///------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  final String userName;
  final bool hasAssessment;
  final String predictionResult;
  final String riskLevel;
  final String probability;
  final String createdAt;

  const _HeaderSection({
    required this.userName,
    required this.hasAssessment,
    required this.predictionResult,
    required this.riskLevel,
    required this.probability,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        WelcomeHeader(
          userName: userName,
          profileImageUrl: "assets/images/defualt_profile.png",
          hasAssessment: hasAssessment,
        ),
        if (hasAssessment)
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: _LatestAssessmentCard(
              predictionResult,
              riskLevel,
              probability,
              createdAt,
            ),
          )
      ],
    );
  }
}

///------------------------------------------------------------
/// BODY
///------------------------------------------------------------

class _BodySection extends StatelessWidget {
  final ProfileSuccessState state;
  final bool hasAssessment;
  final String predictionResult;
  final String riskLevel;
  final String probability;
  final String createdAt;

  const _BodySection({
    required this.state,
    required this.hasAssessment,
    required this.predictionResult,
    required this.riskLevel,
    required this.probability,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: hasAssessment ? 120 : 40),

          const SizedBox(height: 24),

          Text(
            "quickActions".tr(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          const SizedBox(height: 12),

          const _QuickActionTile(
            icon: Icons.favorite_border,
            color: Colors.blue,
            title: "NewAssessment",
            subtitle: "takeAssessment",
          ),

          const SizedBox(height: 12),

          const _QuickActionTile(
            icon: Icons.calendar_today,
            color: Colors.teal,
            title: "ViewHistory",
            subtitle: "SeePastAssessments",
          ),

          const SizedBox(height: 12),

          const _QuickActionTile(
            icon: Icons.location_on_outlined,
            color: Colors.purple,
            title: "FindDoctors",
            subtitle: "ConnectWithCardiologists",
          ),

          const SizedBox(height: 24),

          if (hasAssessment) ...[
            HistoryHeader(),
            const SizedBox(height: 12),
            
            HistoryCard(
              assessment: state.assessments.first,
              predictionResult: state.assessments.first.predictionResult,
              riskLevel: state.assessments.first.riskLevel,
              probability: state.assessments.first.probability,
              createdAt: state.assessments.first.createdAt,
            ),
          ],

//           Column(
//   children: state.assessments.map((item) {
//     return _HistoryCard(
//       predictionResult: item.predictionResult,
//       riskLevel: item.riskLevel,
//       probability: item.probability,
//       createdAt: item.createdAt,
//       riskTitle: item.riskTitle,
//       riskHint: item.riskHint,
//       riskMessage: item.riskMessage,
//       riskColor: item.riskColor,
//       riskBadgeColor: item.riskBadgeColor,
//     );
//   }).toList(),
// )

          const SizedBox(height: 80)
        ],
      ),
    );
  }
}

///------------------------------------------------------------
/// LATEST CARD
///------------------------------------------------------------

class _LatestAssessmentCard extends StatelessWidget {
  final String predictionResult;
  final String riskLevel;
  final String probability;
  final String createdAt;

  const _LatestAssessmentCard(
      this.predictionResult, this.riskLevel, this.probability, this.createdAt);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LatestAssessment".tr(),
                  style: const TextStyle(color: Colors.grey)),
              CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.favorite, color: Colors.red),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMMM d, y').format(DateTime.parse(createdAt)),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricItem(title: "Status", value: predictionResult),
              MetricItem(title: "RiskLevel", value: riskLevel),
              MetricItem(title: "Probability", value: probability),
            ],
          )
        ],
      ),
    );
  }
}

///------------------------------------------------------------
/// HISTORY CARD
///------------------------------------------------------------

///------------------------------------------------------------
/// QUICK ACTION TILE
///------------------------------------------------------------

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  subtitle.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

///------------------------------------------------------------
/// METRIC ITEM
///------------------------------------------------------------

// class _MetricItem extends StatelessWidget {
//   final String title;
//   final String value;

//   const _MetricItem({
//     required this.title,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(title.tr(),
//             style: const TextStyle(color: Colors.grey, fontSize: 11)),
//         const SizedBox(height: 4),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//       ],
//     );
//   }
// }

// ///------------------------------------------------------------
// /// CARD STYLE
// ///------------------------------------------------------------

// BoxDecoration _cardDecoration() {
//   return BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(14),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.05),
//         blurRadius: 8,
//       )
//     ],
//   );
// }
