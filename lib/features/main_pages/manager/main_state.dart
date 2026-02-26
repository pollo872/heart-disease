abstract class MainState {}

class MainInitialState extends MainState {
  final int currentIndex;
  MainInitialState({this.currentIndex = 0});
}

class MainIndexChangedState extends MainState {
  final int currentIndex;
  MainIndexChangedState(this.currentIndex);
}


