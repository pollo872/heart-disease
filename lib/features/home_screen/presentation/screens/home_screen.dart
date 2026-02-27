import 'package:flutter/material.dart';
import 'package:heart_disease/features/home_screen/presentation/widgets/header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WelcomeHeader(userName: 'polla', profileImageUrl: 'assets/images/defualt_profile.png'),
        Center(child: const Text('home screen'),),
      ],
    );
  }
}