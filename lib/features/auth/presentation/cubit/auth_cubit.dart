import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/auth/domain/use_cases/check_login_usecase.dart';
import 'package:heart_disease/features/auth/domain/use_cases/login_usecase.dart';
import 'package:heart_disease/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:heart_disease/features/auth/domain/use_cases/signup_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final CheckLoginUseCase checkLoginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit(this.loginUseCase, this.checkLoginUseCase, this.logoutUseCase,
      this.signUpUseCase)
      : super(AuthInitial());
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(email, password);

      emit(AuthSuccess(
        token: result.token,
        user: result.user,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(
      {required String email,
      required String firstName,
      required String lastName,
      required String password}) async {
    emit(AuthLoading());

    try {
      final result = await signUpUseCase(email, firstName, lastName, password);
      

      emit(AuthSuccess(
        token: result.token,
        user: result.user,
      ));
    } catch (e) {
      

      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkLogin() async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await checkLoginUseCase();

      if (isLoggedIn) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}
