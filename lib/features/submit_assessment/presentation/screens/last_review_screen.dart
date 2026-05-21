import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();
    final model = cubit.model;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Review Your Information'.tr(),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please verify all details before submitting'.tr(),
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // ── Demographics & Vitals ──────────────────────────
            _SectionCard(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF1E63F3),
              title: 'Demographics & Vitals',
              child: Column(
                children: [
                  Row(
                    children: [
                      _InfoTile(label: 'Age', value: model.age ?? '—'),
                      _InfoTile(label: 'Sex', value: 'sex.${model.sex}'.tr()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoTile(
                          label: 'Weight',
                          value: model.weight != null
                              ? '${model.weight} kg'
                              : '—'),
                      _InfoTile(
                          label: 'Height',
                          value: model.height != null
                              ? '${model.height} cm'
                              : '—'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoTile(label: 'Race', value: 'race.${model.race}'.tr()),
                      _InfoTile(
                          label: 'BMI',
                          value: model.bmi != null
                              ? model.bmi!.toStringAsFixed(1)
                              : '—'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Lifestyle & Habits ─────────────────────────────
            _SectionCard(
              icon: Icons.bolt_outlined,
              iconColor: Colors.amber,
              title: 'Lifestyle & Habits',
              child: Column(
                children: [
                  _LabelValue(
                      label: 'Smoking Status', value: 'YesNo.${model.smoking}'),
                  _LabelValue(
                      label: 'Drinking Alcohol', value: 'YesNo.${model.alcohol}'),
                  _LabelValue(
                      label: 'Physical activity',
                      value: 'YesNo.${model.physicalActivity}'),
                  _LabelValue(
                      label: 'Difficulty walking',
                      value: 'YesNo.${model.difficultyWalking}'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Medical History ────────────────────────────────
            _SectionCard(
              icon: Icons.favorite_border,
              iconColor: Colors.redAccent,
              title: 'Medical History',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Past Heart Conditions'.tr(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(label: 'heart attack'),
                      _Chip(label: 'heart failure'),
                    ],
                  ),
                  const SizedBox(height: 10),
                   Text(
                    'Family History'.tr(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                   Text(
                    'None reported'.tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Ready to Submit ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB8D4FF), width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF1E63F3), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(
                          'Ready to Submit'.tr(),
                          style: TextStyle(
                            color: Color(0xFF1E63F3),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your information will be analyzed'.tr(),
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            BaseButton(
              buttonTitle: "Submit Assessment",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xFF1E63F3),
              onPressed: () async {
                await cubit.submit();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.tr(),
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.tr(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value.tr(),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.tr(),
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFD32F2F),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
