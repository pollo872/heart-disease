// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // REQUIRED IMPORT
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nemo/core/routes/app_routes.dart';
// import 'package:nemo/core/shared/widgets/base_button.dart';
// import 'package:nemo/res/text_style.dart';
// import 'package:pinput/pinput.dart';

// import '../bloc/auth_bloc.dart';
// import '../bloc/auth_event.dart';
// import '../bloc/auth_state.dart';

// class OtpScreen extends StatefulWidget {
//   final String? username;

//   const OtpScreen({super.key, required this.username});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _otpController.dispose();
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

//   void _onResendPressed(BuildContext context) {
//     if (widget.username != null) {
//       context.read<AuthBloc>().add(ResendOtpRequested(widget.username!));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('New OTP code requested.'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorTheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     final username = widget.username;
//     if (username == null) {
//       return const Scaffold(
//           body: Center(child: Text("Error: Username missing for OTP.")));
//     }

//     return BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is OtpVerified) {
//             // IMPORTANT: Pass the username to the next screen!
//             context.push(
//               AppRoutes.resetPasswordPath,
//               extra: state.username,
//             );
//           } else if (state is AuthFailure) {
//             _showErrorSnackbar(context, state.message);
//           } else if (state is OtpVerificationFailure) {
//             _showErrorSnackbar(context, state.message);
//           }
//         },
//         child: Scaffold(
//           backgroundColor: colorTheme.primary,
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 110,
//                 ),
//                 Center(
//                   child: Container(
//                     height: 220,
//                     width: 200,
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(30)),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: 27,
//                         ),
//                         SvgPicture.asset(
//                           "assets/images/logo.svg",
//                           height: 136,
//                           width: 185,
//                         ),
//                         SizedBox(
//                           height: 13,
//                         ),
//                         Text(
//                           "N u m o",
//                           style: TextStyle(
//                               fontSize: 30,
//                               color: colorTheme.onPrimary,
//                               fontWeight: FontWeight.w700),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   height: 687,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20))),
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                         top: 55, bottom: 20, right: 25, left: 25),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.only(left: 12),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 "Confirm OTP",
//                                 style: TextStyle(
//                                   fontSize: AppTextStyles.headline2.fontSize,
//                                   fontFamily:
//                                       AppTextStyles.headline1.fontFamily,
//                                   fontWeight:
//                                       AppTextStyles.headline1.fontWeight,
//                                   color: colorTheme.onSurface,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 15,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 12.0),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 "Please enter the OTP sent to: \n$username",
//                                 // Display the actual username
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     color: colorTheme.onSurface,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           Pinput(
//                             length: 4,
//                             controller: _otpController,
//                             defaultPinTheme: PinTheme(
//                               width: 76,
//                               height: 76,
//                               textStyle: TextStyle(
//                                   fontSize: 32,
//                                   color: colorTheme.onSurface,
//                                   fontWeight: FontWeight.w600),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color:
//                                         colorTheme.onSurface.withOpacity(0.3)),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               margin: const EdgeInsets.symmetric(horizontal: 6),
//                             ),
//                             validator: (s) {
//                               return (s != null && s.length == 4)
//                                   ? null
//                                   : 'Enter 4 digit code';
//                             },
//                           ),
//                           SizedBox(
//                             height: 15,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Did't receive OTP ?",
//                                 style: TextStyle(
//                                   color: colorTheme.onSurface,
//                                   fontFamily: AppTextStyles.body5.fontFamily,
//                                   fontSize: 14,
//                                   fontWeight: AppTextStyles.body5.fontWeight,
//                                 ),
//                               ),
//                               TextButton(
//                                   onPressed: () => _onResendPressed(context),
//                                   child: Text(
//                                     "Resend",
//                                     style: TextStyle(
//                                       color: colorTheme.primary,
//                                       fontFamily:
//                                           AppTextStyles.body5.fontFamily,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   )),
//                             ],
//                           ),
//                           BlocBuilder<AuthBloc, AuthState>(
//                               builder: (context, state) {
//                             final bool isLoading = state is AuthLoading;

//                             return Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: SizedBox(
//                                   width: double.infinity,
//                                   height: 60,
//                                   child: BaseButton(
//                                     buttonTitle: isLoading
//                                         ? "Verifying..."
//                                         : "Confirm OTP",
//                                     titleColor: colorTheme.onPrimary,
//                                     borderRadius: 8,
//                                     borderColor: colorTheme.primary,
//                                     backgroundColor: colorTheme.primary,
//                                     onPressed: isLoading
//                                         ? null
//                                         : () {
//                                             if (_formKey.currentState!
//                                                 .validate()) {
//                                               context.read<AuthBloc>().add(
//                                                     OtpSubmitted(
//                                                       username,
//                                                       _otpController.text,
//                                                     ),
//                                                   );
//                                             }
//                                           },
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ));
//   }
// }
