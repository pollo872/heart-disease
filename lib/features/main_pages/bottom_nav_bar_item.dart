// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:heart_disease/res/app_colors.dart';



class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final iconList = <IconData>[
      // Assets.svgHome,
      // Assets.svgtasks,
      // Assets.svgStatus,
      // Assets.svgGroups,
      // Assets.svgProfile
      Icons.home_rounded,
      Icons.assessment_outlined,
      Icons.bar_chart_rounded,
      Icons.notifications_outlined,
      Icons.person,
    ];

    final iconTitles = [
      // AppStrings.home,
      // AppStrings.tasks,
      // AppStrings.status,
      // AppStrings.groups,
      // AppStrings.profile,
      'Home',
      'History',
      'Doctors',
      'Articles',
      'Chat',
    ];

    return Container(
      // margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backGround,
        
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(iconList.length, (index) {
          return _buildNavItem(iconTitles[index], iconList[index], index);
        }),
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, int index) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.mainGreyIcons,
            ),
            const SizedBox(width: 6),
            AnimatedCrossFade(
              firstChild: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.mainGreyIcons,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 150),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}
