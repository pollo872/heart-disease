abstract class UpdateProfileState {}
class UpdateProfileInitial extends UpdateProfileState {}
class UpdateProfileLoading extends UpdateProfileState {}
class UpdateProfileSuccess extends UpdateProfileState {}
class UpdateProfileError extends UpdateProfileState {
  final String message;
  UpdateProfileError(this.message);
}