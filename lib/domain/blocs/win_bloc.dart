import 'package:matchymatchy/domain/domain.dart';

class WinBloc extends BlocEventStateBase<WinEvent, WinState> {
  final WinRepo _repo;

  WinBloc(this._repo) : super(initialState: WinState.waitingForOpp());

  @override
  Stream<WinState> eventHandler(WinEvent event, WinState currentState) async* {
    switch (event.type) {
      case WinEventType.single:
        yield WinState(type: WinStateType.waitingForOpp);
        break;
      case WinEventType.multi:
        yield WinState(type: WinStateType.waitingForOpp);
        break;
      default:
    }
  }
}
