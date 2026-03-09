import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heart_disease/profile.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const WelcomeHeader({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff1E63F3),
            Color(0xff2F7BFF),
          ],
        ),
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
                  // TODO: open notifications
                },
              ),
            ),

            const SizedBox(width: 10),

            /// PROFILE IMAGE
            GestureDetector(
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
                  backgroundImage: NetworkImage(profileImageUrl),
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
