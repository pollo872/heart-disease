import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/utils/error_message_handler.dart';
import 'package:heart_disease/features/update_profile/data/models/update_profile_model.dart';
import 'package:heart_disease/features/update_profile/data/repositories/update_profile_repo.dart';
import 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  final UpdateProfileRepository repo;
  UpdateProfileCubit(this.repo) : super(UpdateProfileInitial());

  Future<void> updateProfile(UpdateProfileModel model) async {
    emit(UpdateProfileLoading());
    final result = await repo.updateProfile(model.toJson());
    result.fold(
      (failure) => emit(UpdateProfileError(ErrorMessageHandler.getMessage(failure))),
      (_) => emit(UpdateProfileSuccess()),
    );
  }
}