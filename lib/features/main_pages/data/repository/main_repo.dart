import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
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

}