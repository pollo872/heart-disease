import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';

import '../../data/models/patient_model.dart';
import 'main_event.dart';
import 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  int currentIndex = 0;

  final MainRepo mainRepo;

  MainBloc(this.mainRepo) : super(MainInitialState()) {
    on<MainTabChangedEvent>(_onTabChanged);
    on<GetProfileEvent>(_getProfile);
  }

  void _onTabChanged(
    MainTabChangedEvent event,
    Emitter<MainState> emit,
  ) {
    currentIndex = event.index;
    if(currentIndex == 0){
      add(GetProfileEvent());
    }
    emit(MainIndexChangedState(currentIndex));
    
  }

  Future<void> _getProfile(
    GetProfileEvent event,
    Emitter<MainState> emit,
  ) async {
    emit(ProfileLoadingState());

    try {
      final PatientModel patient = await mainRepo.getProfile();
      final AssessmentModel assessment = await mainRepo.getLatestHealthData();

      emit(ProfileSuccessState(patient, assessment));
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }
}