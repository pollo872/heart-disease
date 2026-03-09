import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/home_screen/presentation/widgets/header.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return Center(child: const CircularProgressIndicator());
        }

        if (state is ProfileSuccessState) {
          return _content("${state.patient.firstName} ${state.patient.lastName}");
        }

        if (state is ProfileErrorState) {
          return Text(state.error);
        }

        return const SizedBox();
      },
    );
  
    
  }
  Widget _content(String userName) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                /// 🔵 HEADER
                WelcomeHeader(
                  userName: userName,
                  profileImageUrl: "assets/images/defualt_profile.png",
                ),

                /// 🟦 FLOATING LATEST ASSESSMENT CARD
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: _LatestAssessmentCard(),
                ),
              ],
            ),
            SizedBox(height: 100),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  /// Quick Actions
                  Text(
                    "quickActions".tr(),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  _QuickActionTile(
                    icon: Icons.favorite_border,
                    color: Colors.blue,
                    title: "NewAssessment".tr(),
                    subtitle: "takeAssessment".tr(),
                  ),

                  const SizedBox(height: 12),

                  _QuickActionTile(
                    icon: Icons.calendar_today,
                    color: Colors.teal,
                    title: "ViewHistory".tr(),
                    subtitle: "SeePastAssessments".tr(),
                  ),

                  const SizedBox(height: 12),

                  _QuickActionTile(
                    icon: Icons.location_on_outlined,
                    color: Colors.purple,
                    title: "FindDoctors".tr(),
                    subtitle: "ConnectWithCardiologists".tr(),
                  ),

                  const SizedBox(height: 24),

                  /// Assessment History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "AssessmentHistory".tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, size: 16),
                        label: Text("Export".tr()),
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  _HistoryCard(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  
  }
}

class _LatestAssessmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Heart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LatestAssessment".tr(),
                style: TextStyle(color: Colors.grey),
              ),
              CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.favorite, color: Colors.red),
              )
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            "August 5, 2024",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _MetricItem(title: "Risk Score", value: "38%"),
              _MetricItem(title: "Blood Pressure", value: "132/84"),
              _MetricItem(title: "Cholesterol", value: "220"),
            ],
          )
        ],
      ),
    );
  }
}

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
      decoration: _cardDecoration(),
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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

class _HistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Date + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "August 5, 2024",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Moderate Risk",
                  style: TextStyle(color: Colors.orange, fontSize: 11),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Needs Attention",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffE9EEF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricItem(title: "Risk Score", value: "38%"),
                _MetricItem(title: "BP", value: "132/84"),
                _MetricItem(title: "Cholesterol", value: "220"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffDCE6F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Initial assessment. Follow dietary recommendations.",
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String title;
  final String value;

  const _MetricItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
      )
    ],
  );
}
