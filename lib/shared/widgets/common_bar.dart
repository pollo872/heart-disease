import 'package:flutter/material.dart';


import 'package:heart_disease/theme/app_theme.dart';

Widget commonBarWidget(
  BuildContext context,
  
  String title,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
         Navigator.pop(context);
        },
      ),
      SizedBox(height: 10),
      Text(
        title,
        
        style: const TextStyle(
          color: AppColors.textBlue ,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
