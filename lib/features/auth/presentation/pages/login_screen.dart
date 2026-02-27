import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_state.dart';
import 'package:heart_disease/features/auth/presentation/pages/signup_screen.dart';
import 'package:heart_disease/features/auth/presentation/widgets/logo.dart';
import 'package:heart_disease/features/main_pages/main_screen.dart';
import 'package:heart_disease/res/app_colors.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';
import 'package:heart_disease/shared/widgets/form_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  /// ✅ LOGIN SUCCESS → GO TO MAIN PAGE
                  if (state is AuthSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainScreen(),
                      ),
                    );
                  }

                  /// ❌ LOGIN ERROR
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: _content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(context, state) {
    return Column(
      children: [
        const SizedBox(height: 40),
        LogoWidget(),
        const SizedBox(height: 30),
        _body(state, context),
      ],
    );
  }

  Container _body(AuthState state, BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backGround,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("WelcomeBack"),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
           Text(
            tr("signInToAccessYourDashboard"),
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          /// EMAIL
          AnyFormFeild(
            formTitle: "Email",
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("emailRequired");
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          /// PASSWORD
          PasswordFormFeild(
            formTitle: "Password",
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr("passwordRequired");
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          /// BUTTON
          _signInBtn(state, context),
          const SizedBox(height: 16),
          _signUpNavigationBtn()
        ],
      ),
    );
  }

  BaseButton _signInBtn(AuthState state, BuildContext context) {
    return BaseButton(
      buttonTitle:
          state is AuthLoading ? tr("signInLoadingTitle") : tr("signInTitle"),
      titleColor: AppColors.textWhite,
      borderRadius: 10,
      borderColor: Colors.transparent,
      backgroundColor: state is AuthLoading ? Colors.grey : AppColors.primary,
      onPressed: state is AuthLoading
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthCubit>().login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
              }
            },
    );
  }

  Center _signUpNavigationBtn() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
            ),
          );
        },
        child: Text(
          tr("signupBotton"),
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }
}
