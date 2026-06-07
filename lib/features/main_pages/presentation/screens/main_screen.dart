import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/chat/presentation/screens/chat_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/article_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/home_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/history_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/profile.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/bottom_nav_bar_item.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      // ✅ بيبني بس لو الـ index اتغير
      buildWhen: (previous, current) =>
          current is MainIndexChangedState || current is MainInitialState,
      builder: (context, state) {
        final currentIndex = context.read<MainBloc>().currentIndex;

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          backgroundColor: Colors.transparent,
          // ✅ بيخلي كل الـ screens تتبني مرة واحدة وتفضل موجودة
          body: IndexedStack(
            index: currentIndex,
            children: const [
              HomeScreen(),
              HistoryScreen(),
              ArticlesScreen(),
              ChatPage(),
              ProfileScreen(),
              SizedBox(),
            ],
          ),
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