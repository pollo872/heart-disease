import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/home_screen/presentation/screens/home_screen.dart';
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
      const HistoryScreen(),
      const DoctorsScreen(),
      const ArticlesScreen(),
      const ChatScreen(),
      const SizedBox(),
    ];

    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {

        int currentIndex = 0;

        if (state is MainIndexChangedState) {
          currentIndex = state.currentIndex;
        } else if (state is MainInitialState) {
          currentIndex = state.currentIndex;
        }

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