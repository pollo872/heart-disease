import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';
import 'package:heart_disease/theme/app_theme.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      // buildWhen: (previous, current) =>
      //     current is GetProfileLoadingState ||
      //     current is GetProfileSuccessState ||
      //     current is GetProfileErrorState,
      builder: (context, state) {
        // if (state is GetProfileLoadingState) {
        //   return const Center(child: MyLoadingWidget());
        // }
        // if (state is GetProfileErrorState) {
        //   return Center(child: Text(state.error));
        // }
        if (state is GetProfileSuccessState) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradiant.gradiant2,
            ),
            height: 36,
            width: 36,
            child: Center(
              child: Text(
                '${state.patient.firstName[0]}${state.patient.lastName[0]}'
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }
        return const Center(child: Text("No Data Yet"));
      },
    );
  }
}
