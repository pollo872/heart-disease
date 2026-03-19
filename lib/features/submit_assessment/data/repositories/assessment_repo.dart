import 'package:dartz/dartz.dart';
import 'package:heart_disease/core/errors/failure.dart';
import 'package:heart_disease/features/submit_assessment/data/data_sources/remote_data_source.dart';

class AssessmentRepository {
  final AssessmentRemoteDataSource remote;

  AssessmentRepository(this.remote);

  Future<Either<Failure, void>> submit(data) async {
    try {
      await remote.submit(data);
      return Right(null);
    } catch (e) {
      return Left(Failure("Failed to submit assessment"));
    }
  }
}