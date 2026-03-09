abstract class MainEvent {}

class MainTabChangedEvent extends MainEvent {
  final int index;
  MainTabChangedEvent(this.index);
}

class GetProfileEvent extends MainEvent {}