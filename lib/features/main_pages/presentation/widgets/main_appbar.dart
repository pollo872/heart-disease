import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heart_disease/profile.dart';
import 'package:heart_disease/res/app_colors.dart';

AppBar mainAppBar(String title, BuildContext context) {
  return AppBar(
    leading: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
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
