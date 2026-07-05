import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/profile_image.dart';
import 'package:heart_disease/theme/app_theme.dart';

AppBar mainAppBar(String title, BuildContext context) {
  return AppBar(
    scrolledUnderElevation: 0,
    leadingWidth: 50,
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          context.read<MainBloc>().add(MainTabChangedEvent(4));
        },
        child: Center(child: ProfileImage()),
      ),
    ),
    title: Text(
      title.tr(),
      style: AppTextStyles.pageTitle,
    ),
    actions: [
      Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.notifications_none,
            color: AppColors.pageTitle,
            size: 25,
          ),
          tooltip: 'Notifications',
          onPressed: () {
          },
        ),
      ),
    ],
    centerTitle: true,
  );
}
