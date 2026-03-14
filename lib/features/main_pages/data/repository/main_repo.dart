import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
import '../models/patient_model.dart';

class MainRepo {
  final MainRemoteDataSource remoteDataSource;

  MainRepo(this.remoteDataSource);

  Future<PatientModel> getProfile() async {
    final response = await remoteDataSource.getProfile();

    return PatientModel.fromJson(
      response.data['patient'],
    );
  }

 Future<AssessmentModel?> getLatestHealthData() async {
  final response = await remoteDataSource.getProfile();

  var data = response.data['latestHealthData'];

  if (data == null) {
    return null;
  }

  return AssessmentModel.fromJson(data);
}
}
