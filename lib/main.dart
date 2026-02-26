import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/network/dio_helper.dart';
import 'package:heart_disease/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:heart_disease/features/auth/data/data_sources/local_data_source.dart';
import 'package:heart_disease/features/auth/data/repo/auth_repository_impl.dart';
import 'package:heart_disease/features/auth/domain/use_cases/check_login_usecase.dart';
import 'package:heart_disease/features/auth/domain/use_cases/login_usecase.dart';
import 'package:heart_disease/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:heart_disease/features/auth/domain/use_cases/signup_usecase.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:heart_disease/features/auth/presentation/pages/welcome_screen.dart';

void main() {
  DioHelper.init();
  final remoteDataSource = AuthRemoteDataSource(DioHelper.dio);
  final localDataSource = AuthLocalDataSource();

  final authRepository = AuthRepositoryImpl(remoteDataSource, localDataSource);
    final loginUseCase = LoginUseCase(authRepository);
  final checkLoginUseCase = CheckLoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  runApp(
    BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(
        loginUseCase,
        checkLoginUseCase,
        logoutUseCase,
        signUpUseCase,
      )..checkLogin(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
