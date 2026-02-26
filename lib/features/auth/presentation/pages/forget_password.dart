// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // REQUIRED IMPORT
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../../core/routes/app_routes.dart';
// import '../../../../../core/shared/widgets/base_button.dart';
// import '../../../../../core/shared/widgets/form_fields.dart';
// import '../../../../../res/text_style.dart';
// import '../bloc/auth_bloc.dart'; // REQUIRED IMPORT
// import '../bloc/auth_event.dart'; // REQUIRED IMPORT
// import '../bloc/auth_state.dart'; // REQUIRED IMPORT

// class ForgetPassword extends StatefulWidget {
//   const ForgetPassword({super.key});

//   @override
//   State<ForgetPassword> createState() => _ForgetPasswordState();
// }

// class _ForgetPasswordState extends State<ForgetPassword> {
//   // 1. ADD CONTROLLER AND FORM KEY
//   final TextEditingController _emailController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   void _showErrorSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorTheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthPasswordResetCodeSent) {
//           context.push(
//             AppRoutes.otpPath,
//             extra: _emailController.text,
//           );
//         } else if (state is AuthPasswordResetFailure) {
//           _showErrorSnackbar(context, state.message);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: colorTheme.primary,
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 110,
//               ),
//               Center(
//                 child: Container(
//                   height: 220,
//                   width: 200,
//                   decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(30)),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 27,
//                       ),
//                       SvgPicture.asset(
//                         "assets/images/logo.svg",
//                         height: 136,
//                         width: 185,
//                       ),
//                       SizedBox(
//                         height: 13,
//                       ),
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
//               SizedBox(
//                 height: 20,
//               ),
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
//                               "Forget Password",
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
//                           child: Row(
//                             children: [
//                               Text(
//                                 "Remember Password ?",
//                                 style: TextStyle(
//                                   color: colorTheme.onSurface,
//                                   fontFamily: AppTextStyles.body5.fontFamily,
//                                   fontSize: AppTextStyles.body5.fontSize,
//                                   fontWeight: AppTextStyles.body5.fontWeight,
//                                 ),
//                               ),
//                               TextButton(
//                                   onPressed: () {
//                                     context.pop();
//                                   },
//                                   child: Text(
//                                     "Login",
//                                     style: TextStyle(
//                                       color: colorTheme.primary,
//                                       fontFamily:
//                                           AppTextStyles.body5.fontFamily,
//                                       fontSize: AppTextStyles.body5.fontSize,
//                                       fontWeight:
//                                           AppTextStyles.headline1.fontWeight,
//                                     ),
//                                   )),
//                             ],
//                           ),
//                         ),
//                         AnyFormFeild(
//                           formTitle: "E-mail",
//                           keyboardType: TextInputType.emailAddress,
//                           controller: _emailController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your email.';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         BlocBuilder<AuthBloc, AuthState>(
//                             builder: (context, state) {
//                           final bool isLoading = state is AuthLoading;

//                           return Center(
//                             child: Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: SizedBox(
//                                 width: double.infinity,
//                                 height: 60,
//                                 child: BaseButton(
//                                   buttonTitle:
//                                       isLoading ? "Sending..." : "Send OTP",
//                                   titleColor: colorTheme.onPrimary,
//                                   borderRadius: 8,
//                                   borderColor: colorTheme.primary,
//                                   backgroundColor: colorTheme.primary,
//                                   onPressed: isLoading
//                                       ? null
//                                       : () {
//                                           if (_formKey.currentState!
//                                               .validate()) {
//                                             context.read<AuthBloc>().add(
//                                                   ForgotPasswordRequested(
//                                                       _emailController.text),
//                                                 );
//                                             context.push(AppRoutes.otpPath);
//                                           }
//                                         },
//                                 ),
//                               ),
//                             ),
//                           );
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
