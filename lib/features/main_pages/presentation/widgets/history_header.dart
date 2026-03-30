import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "AssessmentHistory".tr(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            label: Text("Export".tr()),
          )
        ],
      ),
    );
  }
}