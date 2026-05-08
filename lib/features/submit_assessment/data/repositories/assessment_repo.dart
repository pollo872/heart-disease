import 'package:dartz/dartz.dart';
import 'package:heart_disease/core/errors/failure.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
import 'package:heart_disease/features/submit_assessment/data/data_sources/remote_data_source.dart';

class AssessmentRepository {
  final AssessmentRemoteDataSource remote;

  AssessmentRepository(this.remote);

  Future<Either<Failure, AssessmentModel>> submit(Map<String, dynamic> data) async {
    try {
      final response = await remote.submit(data);
      return Right(AssessmentModel.fromJson(response.data['data']));
    } catch (e) {
      return Left(Failure("Failed to submit assessment"));
    }
  }
}
// في assessment_repo.dart
