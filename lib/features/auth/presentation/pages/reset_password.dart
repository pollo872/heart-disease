// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // **1. REQUIRED BLoC IMPORT**
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../../core/routes/app_routes.dart';
// import '../../../../../core/shared/widgets/base_button.dart';
// import '../../../../../core/shared/widgets/form_fields.dart';
// import '../../../../../res/text_style.dart';
// import '../bloc/auth_bloc.dart';
// import '../bloc/auth_event.dart';
// import '../bloc/auth_state.dart';

// class ResetPassword extends StatefulWidget {
//   // 2. ACCEPT USERNAME ARGUMENT FROM ROUTER
//   final String? username;

//   const ResetPassword({super.key, required this.username});

//   @override
//   State<ResetPassword> createState() => _ResetPasswordState();
// }

// class _ResetPasswordState extends State<ResetPassword> {
//   // 3. CONTROLLERS AND FORM KEY
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _showFeedbackSnackbar(BuildContext context, String message,
//       {bool isError = true}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorTheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     final username = widget.username;
//     if (username == null) {
//       // Safety check: Should not happen if GoRouter is set up correctly
//       return const Scaffold(
//           body: Center(
//               child: Text("Error: Username missing for password reset.")));
//     }

//     // 4. BLoC LISTENER FOR SUCCESS/FAILURE
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is PasswordResetSuccess) {
//           // 🚀 SUCCESS: Password updated. Navigate back to login and clear navigation history.
//           _showFeedbackSnackbar(
//               context, "Password successfully reset. Please log in.",
//               isError: false);
//           // Use context.go to pop all screens and land on the login screen
//           context.go(AppRoutes.loginPath);
//         } else if (state is AuthFailure) {
//           _showFeedbackSnackbar(context, state.message);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: colorTheme.primary,
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 110),
//               Center(
//                 child: Container(
//                   height: 220,
//                   width: 200,
//                   decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(30)),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 27),
//                       SvgPicture.asset(
//                         "assets/images/logo.svg",
//                         height: 136,
//                         width: 185,
//                       ),
//                       SizedBox(height: 13),
//                       Text(
//                         "N u m o",
//                         style: TextStyle(
//                             fontSize: 30,
//                             color: colorTheme.onPrimary,
//                             fontWeight: FontWeight.w700),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 height: 687,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20))),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       top: 55, bottom: 20, right: 25, left: 25),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(left: 12),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               "Reset Password",
//                               style: TextStyle(
//                                 fontSize: AppTextStyles.headline2.fontSize,
//                                 fontFamily: AppTextStyles.headline1.fontFamily,
//                                 fontWeight: AppTextStyles.headline1.fontWeight,
//                                 color: colorTheme.onSurface,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 12),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               "Enter your new password for $username to complete the reset process.",
//                               style: TextStyle(
//                                 color: colorTheme.onSurface,
//                                 fontFamily: AppTextStyles.body5.fontFamily,
//                                 fontSize: AppTextStyles.body5.fontSize,
//                                 fontWeight: AppTextStyles.body5.fontWeight,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 15),
//                         PasswordFormFeild(
//                           formTitle: "New Password",
//                           controller: _newPasswordController,
//                           validator: (value) {
//                             if (value == null || value.length < 6) {
//                               return 'Password must be at least 6 characters.';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 15),
//                         PasswordFormFeild(
//                           formTitle: "Confirm Password",
//                           controller: _confirmPasswordController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please confirm your password.';
//                             }
//                             if (value != _newPasswordController.text) {
//                               return 'Passwords do not match.';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 35),
//                         BlocBuilder<AuthBloc, AuthState>(
//                             builder: (context, state) {
//                           final bool isLoading = state is AuthLoading;
//                           return Center(
//                               child: Padding(
//                                   padding: const EdgeInsets.all(5.0),
//                                   child: SizedBox(
//                                       width: double.infinity,
//                                       height: 60,
//                                       child: BaseButton(
//                                         buttonTitle: isLoading
//                                             ? "Updating..."
//                                             : "Confirm Password",
//                                         titleColor: colorTheme.onPrimary,
//                                         borderRadius: 8,
//                                         borderColor: colorTheme.primary,
//                                         backgroundColor: colorTheme.primary,
//                                         onPressed: isLoading
//                                             ? null
//                                             : () {
//                                                 if (_formKey.currentState!
//                                                     .validate()) {
//                                                   // 8. DISPATCH EVENT
//                                                   context.read<AuthBloc>().add(
//                                                         ResetPasswordSubmitted(
//                                                           username,
//                                                           _newPasswordController
//                                                               .text,
//                                                         ),
//                                                       );
//                                                 }
//                                               },
//                                       ))));
//                         }),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
