import 'package:heart_disease/features/main_pages/data/data_source/get_profile_remote_data_source.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
import '../models/patient_model.dart';

// main_repo.dart
class MainRepo {
  final MainRemoteDataSource remoteDataSource;
  MainRepo(this.remoteDataSource);

  // ✅ call واحد بس بيرجع كل الداتا
  Future<ProfileData> getFullProfile() async {
    final response = await remoteDataSource.getProfile();
    final data = response.data;

    final patient = PatientModel.fromJson(data['patient']);
    
    final latestRaw = data['latestHealthData'];
    final latestAssessment = latestRaw != null 
        ? AssessmentModel.fromJson(latestRaw) 
        : null;

    final allRaw = data['allHealthData'] as List? ?? [];
    final allAssessments = allRaw
        .map((item) => AssessmentModel.fromJson(item))
        .toList();

    return ProfileData(
      patient: patient,
      latestAssessment: latestAssessment,
      allAssessments: allAssessments,
    );
  }
}

// model بسيط يجمع الداتا
class ProfileData {
  final PatientModel patient;
  final AssessmentModel? latestAssessment;
  final List<AssessmentModel> allAssessments;

  ProfileData({
    required this.patient,
    required this.latestAssessment,
    required this.allAssessments,
  });
}