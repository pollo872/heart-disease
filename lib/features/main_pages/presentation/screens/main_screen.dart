import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/chat/presentation/manager/chat_cubit.dart';
import 'package:heart_disease/features/chat/data/repo/chat_repository.dart';
import 'package:heart_disease/features/chat/presentation/screens/chat_screen.dart';

import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/article_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/home_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/history_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/profile.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/bottom_nav_bar_item.dart';
import 'package:heart_disease/features/main_pages/presentation/init_navbar_screens/init_navbar_screens.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const HistoryScreen(), // ← من غير BlocProvider جديد
      const ArticlesScreen(),
      const ChatPage(),
      const ProfileScreen(),
      const SizedBox(),
    ];

    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        final currentIndex =
            context.read<MainBloc>().currentIndex; // ← من الـ bloc

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: screens[currentIndex],
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<MainBloc>().add(MainTabChangedEvent(index));
            },
          ),
        );
      },
    );
  }
}
