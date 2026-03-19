import 'package:get_it/get_it.dart';
import 'package:heart_disease/features/submit_assessment/data/data_sources/remote_data_source.dart';
import 'package:heart_disease/features/submit_assessment/data/repositories/assessment_repo.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';

final sl = GetIt.instance;

void init() {
  /// DataSource
  sl.registerLazySingleton(() => AssessmentRemoteDataSource());

  /// Repository
  sl.registerLazySingleton(
    () => AssessmentRepository(sl()),
  );

  /// Cubit
  sl.registerFactory(
    () => AssessmentCubit(sl()),
  );
}