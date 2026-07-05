import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/theme/app_theme.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String profileImageUrl;
  final bool hasAssessment;

  const WelcomeHeader({
    super.key,
    required this.userName,
    required this.profileImageUrl,
    required this.hasAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: hasAssessment ? 150 : 110,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: AppGradiant.gradiant1,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// TEXT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "welcomeBack".tr(),
                  style: AppTextStyles.subTitle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: AppTextStyles.subTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// NOTIFICATION ICON
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                },
              ),
            ),

            const SizedBox(width: 10),

            /// PROFILE IMAGE
            GestureDetector(
              onTap: () {
                context.read<MainBloc>().add(MainTabChangedEvent(4));
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  // backgroundImage: NetworkImage(profileImageUrl),
                  backgroundImage:
                      AssetImage("assets/images/defualt_profile.png"),

                  onBackgroundImageError: (_, __) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
