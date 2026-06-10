import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/data/models/patient_model.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/update_profile/data/data_source/update_profile_remote_data_source.dart';
import 'package:heart_disease/features/update_profile/data/models/update_profile_model.dart';
import 'package:heart_disease/features/update_profile/data/repositories/update_profile_repo.dart';
import 'package:heart_disease/features/update_profile/presentation/manager/update_profile_cubit.dart';
import 'package:heart_disease/features/update_profile/presentation/manager/update_profile_state.dart';
import 'package:heart_disease/shared/widgets/form_fields.dart';

class EditProfileSheet extends StatelessWidget {
  final PatientModel patient;
  const EditProfileSheet({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateProfileCubit(
        UpdateProfileRepository(UpdateProfileRemoteDataSource()),
      ),
      child: _EditProfileSheetContent(patient: patient),
    );
  }
}

class _EditProfileSheetContent extends StatefulWidget {
  final PatientModel patient;
  const _EditProfileSheetContent({required this.patient});

  @override
  State<_EditProfileSheetContent> createState() =>
      _EditProfileSheetContentState();
}

class _EditProfileSheetContentState extends State<_EditProfileSheetContent> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.patient.firstName);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _emailController = TextEditingController(text: widget.patient.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UpdateProfileCubit>();

    return BlocListener<UpdateProfileCubit, UpdateProfileState>(
      listener: (context, state) {
        if (state is UpdateProfileSuccess) {
          context.read<MainBloc>().invalidateCache();
          context.read<MainBloc>().add(GetProfileEvent());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context);
        }
        if (state is UpdateProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        // ← الحاوية الرئيسية للـ bottom sheet
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // ← عشان الكيبورد
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ← مهم جداً للـ bottom sheet
              children: [
                // ── Handle ──────────────────────────────────────
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Title ────────────────────────────────────────
                Text(
                  'Edit Profile'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Divider(height: 24, color: Colors.grey.shade200),

                // ── Avatar ──────────────────────────────────────
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1E63F3),
                  child: Text(
                    '${widget.patient.firstName[0]}${widget.patient.lastName[0]}'
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                ///image picker////////////////
                // Positioned(
                //   bottom: 0,
                //   right: 0,
                //   child: Container(
                //     padding: const EdgeInsets.all(5),
                //     decoration: const BoxDecoration(
                //       color: Color(0xFF1E63F3),
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(Icons.camera_alt,
                //         color: Colors.white, size: 13),
                //   ),
                // ),
                // const SizedBox(height: 8),
                //  Text(
                //   'Change photo',
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                const SizedBox(height: 20),

                // ── Fields ──────────────────────────────────────
                AnyFormFeild(
                  formTitle: 'FirstName',
                  keyboardType: TextInputType.name,
                  controller: _firstNameController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AnyFormFeild(
                  formTitle: 'LastName',
                  keyboardType: TextInputType.name,
                  controller: _lastNameController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AnyFormFeild(
                  formTitle: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // ── Buttons ─────────────────────────────────────
                BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
                  builder: (context, state) {
                    final isLoading = state is UpdateProfileLoading;
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text('Cancel'.tr(),
                                style: TextStyle(color: Colors.black87)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      cubit.updateProfile(
                                        UpdateProfileModel(
                                          firstName:
                                              _firstNameController.text.trim(),
                                          lastName:
                                              _lastNameController.text.trim(),
                                          email: _emailController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E63F3),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text('Save Changes'.tr(),
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
