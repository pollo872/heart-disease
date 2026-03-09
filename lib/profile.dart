import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:heart_disease/features/auth/presentation/pages/login_screen.dart';
import 'package:heart_disease/core/change_language/change_language_screen.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text(
          "profile",
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// USER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xff1E63F3),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "John Anderson",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "john.anderson@email.com",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Member since Nov 2024",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// EDIT PROFILE BUTTON
            BaseButton(
              buttonTitle: "Edit Profile",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xff1E63F3),
              onPressed: () {
                // TODO: Navigate to Edit Profile
              },
            ),

            const SizedBox(height: 24),

            /// APP SETTINGS
            _SectionTitle(title: "App Settings"),
            _SettingCard(
              child: Row(
                children: [
                  _IconBox(icon: Icons.notifications, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Notifications",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text(
                          "Health alerts & reminders",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: notificationsEnabled,
                    onChanged: (v) {
                      setState(() => notificationsEnabled = v);
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.language,
              iconColor: Colors.purple,
              title: "Language",
              subtitle: "English (US)",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LanguageScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            /// SECURITY & PRIVACY
            _SectionTitle(title: "Security & Privacy"),
            _SettingTile(
              icon: Icons.lock,
              iconColor: Colors.green,
              title: "Change Password",
              subtitle: "Update security credentials",
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.description,
              iconColor: Colors.grey,
              title: "Terms & Privacy",
              subtitle: "Legal information",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            /// LOGOUT
            _SettingTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: "Log Out",
              titleColor: Colors.red,
              onTap: () {
                context.read<AuthCubit>().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
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
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: child,
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    );
  }
}
