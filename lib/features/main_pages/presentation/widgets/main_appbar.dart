import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/res/app_colors.dart';

AppBar mainAppBar(String title, BuildContext context) {
  return AppBar(
    scrolledUnderElevation: 0,
    leading: GestureDetector(
      onTap: () {
       context.read<MainBloc>().add(MainTabChangedEvent(4));
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage("assets/images/defualt_profile.png"),
          onBackgroundImageError: (_, __) {},
        ),
      ),
    ),
   
    title: Text(
      title.tr(),
      style: TextStyle(
        color: AppColors.mainAppBarTitle,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
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
            color: AppColors.mainAppBarTitle,
            size: 25,
          ),
          onPressed: () {
            // TODO: open notifications
          },
        ),
      ),
    ],
    centerTitle: true,
  );
}
