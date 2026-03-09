import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_state.dart';
import 'package:heart_disease/features/auth/presentation/pages/login_screen.dart';
import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => MainBloc(
                  MainRepo(
                    MainRemoteDataSource(),
                  ),
                )..add(GetProfileEvent()),
                child: const MainScreen(),
              ),
            ),
          );
        }

        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
