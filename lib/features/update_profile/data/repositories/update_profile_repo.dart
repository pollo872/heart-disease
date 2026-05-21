import 'package:dartz/dartz.dart';
import 'package:heart_disease/core/errors/failure.dart';
import 'package:heart_disease/features/update_profile/data/data_source/update_profile_remote_data_source.dart';

class UpdateProfileRepository {
  final UpdateProfileRemoteDataSource remote;
  UpdateProfileRepository(this.remote);

  Future<Either<Failure, void>> updateProfile(Map<String, dynamic> data) async {
    try {
      await remote.updateProfile(data);
      return const Right(null);
    } catch (e) {
      return Left(Failure("Failed to update profile"));
    }
  }
}