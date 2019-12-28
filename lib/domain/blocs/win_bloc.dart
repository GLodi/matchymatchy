import 'dart:async';

import 'package:matchymatchy/data/api/mess_event_bus.dart';
import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinBloc extends BlocEventStateBase<WinEvent, WinState> {
  final WinRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _winnerSubs;
  String matchId;

  WinBloc(this._repo, this._messEventBus)
      : super(initialState: WinState.waitingForOpp());

  @override
  Stream<WinState> eventHandler(WinEvent event, WinState currentState) async* {
    switch (event.type) {
      case WinEventType.single:
        yield WinState(type: WinStateType.singleWin, moves: event.moves);
        break;
      case WinEventType.multi:
        matchId = event.matchId;
        yield WinState(type: WinStateType.waitingForOpp);
        listenToMessages();
        break;
      default:
    }
  }

  void listenToMessages() {
    if (_winnerSubs == null) {
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) async {
        if (mess.matchId == matchId) {
          User user = await _repo.getUser();
          ActiveMatch activeMatch = await _repo.getActiveMatch(mess.matchId);
          emitEvent(
              WinEvent.showWinner(mess.winner, user.username, activeMatch));
        }
      });
    }
  }

  @override
  void dispose() {
    if (_winnerSubs != null) _winnerSubs.cancel();
    super.dispose();
  }
}
