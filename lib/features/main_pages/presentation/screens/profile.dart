import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:heart_disease/features/auth/presentation/pages/login_screen.dart';
import 'package:heart_disease/core/change_language/change_language_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/loading.dart';
import 'package:heart_disease/features/update_profile/presentation/screens/edit_profile_screen.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';
import 'package:heart_disease/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen: (previous, current) =>
          current is ProfileLoadingState ||
          current is ProfileSuccessState ||
          current is ProfileErrorState,
      builder: (context, state) {
        // if (state is ProfileLoadingState) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        if (state is ProfileLoadingState) {
          return const Center(child: MyLoadingWidget());
        }

        if (state is ProfileErrorState) {
          return Center(child: Text(state.error));
        }

        if (state is ProfileSuccessState) {
          return Scaffold(
            backgroundColor: Colors.white,
            // appBar: AppBar(
            //   elevation: 0,
            //   backgroundColor: Colors.white,
            //   // leading: IconButton(
            //   //   color: Colors.blue,
            //   //   onPressed: () {
            //   //     Navigator.pop(context);
            //   //   },
            //   //   icon: Icon(Icons.arrow_back),
            //   // ),
            //   title: Text(
            //     "profile".tr(),
            //     style: AppTextStyles.subTitle.copyWith(
            //       color: AppColors.primary,
            //     ),
            //   ),
            //   centerTitle: true,
            // ),
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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradiant.gradiant2,
                          ),
                          height: 80,
                          width: 80,
                          child: Center(
                            child: Text(
                              '${state.patient.firstName[0]}${state.patient.lastName[0]}'
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${state.patient.firstName} ${state.patient.lastName}",
                              style: AppTextStyles.heading
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              state.patient.email,
                              style: AppTextStyles.subTitle,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "${"Joined on".tr()} ${state.patient.createdAt.split('T')[0]}",
                              style: AppTextStyles.subTitle,
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
                    backgroundColor: AppColors.primary,
                    onPressed: () {
                      // بدل Navigator.push استخدم showModalBottomSheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BlocProvider.value(
                          value: context.read<MainBloc>(),
                          child: EditProfileSheet(patient: state.patient),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  /// APP SETTINGS
                  _SectionTitle(title: "App Settings"),
                  _SettingCard(
                    child: Row(
                      children: [
                        _IconBox(
                            icon: Icons.notifications,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notifications".tr(),
                                style: AppTextStyles.subTitle
                                    .copyWith(color: AppColors.textBlack),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Health alerts & reminders".tr(),
                                style: AppTextStyles.subTitle,
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
                    iconColor: Color(0xFF9810FA),
                    title: "Language",
                    subtitle: "LangIs",
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
                    iconColor: Color(0xFF009689),
                    title: "Change Password",
                    subtitle: "Update security credentials",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.description,
                    iconColor: Color(0xFF666666),
                    title: "Terms & Privacy",
                    subtitle: "Legal information",
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  /// LOGOUT
                  _SettingTile(
                    icon: Icons.logout,
                    iconColor: Color(0xFFE7000B),
                    title: "Log Out",
                    titleColor: Color(0xFFE7000B),
                    onTap: () {
                      context.read<AuthCubit>().logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
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
        title.tr(),
        style: AppTextStyles.subTitle.copyWith(color: AppColors.textBlack),
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
                    title.tr(),
                    style: AppTextStyles.subTitle
                        .copyWith(color: titleColor ?? AppColors.textBlack),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!.tr(),
                      style: AppTextStyles.subTitle,
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFFB3B3B3)),
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
