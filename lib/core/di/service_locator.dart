import 'package:get_it/get_it.dart';
import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/submit_assessment/data/data_sources/remote_data_source.dart';
import 'package:heart_disease/features/submit_assessment/data/repositories/assessment_repo.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';

final sl = GetIt.instance;

void init() {
  /// DataSource
  sl.registerLazySingleton(() => AssessmentRemoteDataSource());
   sl.registerLazySingleton(() => MainRemoteDataSource()); 

  /// Repository
  sl.registerLazySingleton(
    () => AssessmentRepository(sl()),
  );
  sl.registerLazySingleton(
    () => MainRepo(sl()),
  );

  /// Cubit
  sl.registerFactory(
    () => AssessmentCubit(sl()),
  );
    sl.registerFactory(                                  
    () => MainBloc(sl())..add(GetProfileEvent()),
  );
}