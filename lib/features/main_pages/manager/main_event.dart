abstract class MainEvent {}

class MainTabChangedEvent extends MainEvent {
  final int index;
  MainTabChangedEvent(this.index);
}
