import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/shared/form_field.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:heart_disease/features/auth/presentation/cubit/auth_state.dart';
import 'package:heart_disease/features/auth/presentation/pages/login_screen.dart';
import 'package:heart_disease/features/auth/presentation/widgets/logo.dart';
import 'package:heart_disease/res/app_colors.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool agree = false;

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
                if (state is AuthSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }

                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              }, builder: _content
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
  
                  /// CARD
                  _body(state, context)
                
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
                        const Text(
                          "Create Account",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Sign up to begin monitoring your heart health",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        AnyFormFeild(
                          formTitle: "First Name",
                          keyboardType: TextInputType.name,
                          controller: firstNameController,
                          validator: (value) =>
                              value!.isEmpty ? "Name required" : null,
                        ),
                        const SizedBox(height: 16),
                        AnyFormFeild(
                          formTitle: "Last Name",
                          keyboardType: TextInputType.name,
                          controller: lastNameController,
                          validator: (value) =>
                              value!.isEmpty ? "Name required" : null,
                        ),
                        const SizedBox(height: 16),
                        AnyFormFeild(
                          formTitle: "Email",
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (value) =>
                              value!.isEmpty ? "Email required" : null,
                        ),
                        const SizedBox(height: 16),
                        PasswordFormFeild(
                          formTitle: "Password",
                          controller: passwordController,
                          validator: (value) =>
                              value!.length < 6 ? "Min 6 characters" : null,
                        ),
                        const SizedBox(height: 16),
                        PasswordFormFeild(
                          formTitle: "Confirm Password",
                          controller: confirmPasswordController,
                          validator: (value) {
                            if (value != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _checkBox(),
                        const SizedBox(height: 20),
                        _createAccountBtn(state, context),
                        const SizedBox(height: 16),
                        signInNavigationBtn(),
                      ],
                    ),
                  );
  }

  Row _checkBox() {
    return Row(
      children: [
        Checkbox(
          value: agree,
          onChanged: (v) {
            setState(() => agree = v!);
          },
        ),
        const Expanded(
          child: Text(
            "I agree to the Terms of Service and Privacy Policy",
            style: TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }

  BaseButton _createAccountBtn(AuthState state, BuildContext context) {
    return BaseButton(
      buttonTitle:
          state is AuthLoading ? "Creating Account..." : "Create Account",
      backgroundColor: state is AuthLoading ? Colors.grey : AppColors.primary,
      titleColor: AppColors.baseBtnColorWhite,
      borderRadius: 10,
      borderColor: AppColors.primary,
      onPressed: state is AuthLoading
          ? null
          : () {
              if (_formKey.currentState!.validate() && agree) {
                context.read<AuthCubit>().register(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
              }
            },
    );
  }

  Center signInNavigationBtn() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "Already have an account? Sign in",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }
}
