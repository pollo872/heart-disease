import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_event.dart';
import 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  int currentIndex = 0;

  MainBloc() : super(MainInitialState()) {
    on<MainTabChangedEvent>(_onTabChanged);
    
  }

  void _onTabChanged(MainTabChangedEvent event, Emitter<MainState> emit) {
    
      currentIndex = event.index;
      emit(MainIndexChangedState(currentIndex));
    
  }
  
}
