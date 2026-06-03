import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/dashboard/presentation/screens/health_dashboard_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/result_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/history_card.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/history_header.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/loading.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/main_appbar.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/new_assessment_card.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/assessment_flow.dart';
import 'package:heart_disease/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  HistoryScreen
// ─────────────────────────────────────────────────────────────────────────────
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return const Center(child: MyLoadingWidget());
        }
        if (state is ProfileErrorState) {
          return Center(child: Text(state.error));
        }
        if (state is ProfileSuccessState) {
          return _HistoryContent(state: state);
        }
        return const Center(child: Text("No Data Yet"));
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HistoryContent  — StatefulWidget عشان نتحكم في الـ toggle
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryContent extends StatefulWidget {
  const _HistoryContent({required this.state});
  final ProfileSuccessState state;

  @override
  State<_HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<_HistoryContent> {
  bool _showDashboard = false; // false = History List | true = Dashboard

  @override
  Widget build(BuildContext context) {
    final assessments = widget.state.assessments;
    final hasAssessment = assessments.isNotEmpty;

    return Scaffold(
      appBar: mainAppBar("History", context),
      body: Column(
        children: [
          // ── زرار New Assessment ──────────────────────────────────────────

          // ── Toggle ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _ToggleBar(
              showDashboard: _showDashboard,
              onChanged: (val) => setState(() => _showDashboard = val),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: _showDashboard
                ? DashboardScreen(assessments: assessments)
                : _HistoryList(
                    state: widget.state,
                    hasAssessment: hasAssessment,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Toggle Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleBar extends StatelessWidget {
  const _ToggleBar({
    required this.showDashboard,
    required this.onChanged,
  });

  final bool showDashboard;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'All Assessments',
            icon: Icons.list_alt_rounded,
            selected: !showDashboard,
            onTap: () => onChanged(false),
          ),
          _ToggleItem(
            label: 'Health Overview',
            icon: Icons.insights_rounded,
            selected: showDashboard,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  History List
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.state,
    required this.hasAssessment,
  });

  final ProfileSuccessState state;
  final bool hasAssessment;

  @override
  Widget build(BuildContext context) {
    if (!hasAssessment) {
      return Column(children: [
        StartAssessmentCard(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AssessmentFlow()),
            );
          },
        ),
        _EmptyHistoryCard()
      ]);
    }

    return Column(
      children: [
        StartAssessmentCard(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AssessmentFlow()),
            );
          },
        ),
        // HistoryHeader(),
        // const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...state.assessments.map((item) {
                  return HistoryCard(
                    predictionResult: item.predictionResult,
                    riskLevel: item.riskLevel,
                    probability: item.probability,
                    createdAt: item.createdAt,
                    assessment: item,
                    onpressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<MainBloc>(),
                            child: ResultScreen(
                              score: double.parse(item.probability),
                              createdAt: item.createdAt,
                              assessment: item,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6ED), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No Assessment History".tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C2A3A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start your first assessment".tr(),
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }
}
