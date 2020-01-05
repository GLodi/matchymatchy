import 'dart:async';

import 'package:matchymatchy/data/api/mess_event_bus.dart';
import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinBloc extends BlocEventStateBase<WinEvent, WinState> {
  final WinRepo _repo;
  StreamSubscription _winnerSubs;
  String matchId;

  WinBloc(this._repo) : super(initialState: WinState.waitingForOpp());

  @override
  Stream<WinState> eventHandler(WinEvent event, WinState currentState) async* {
    switch (event.type) {
      case WinEventType.single:
        yield WinState(type: WinStateType.singleWin, moves: event.moves);
        break;
      case WinEventType.multi:
        matchId = event.matchId;
        yield WinState(type: WinStateType.waitingForOpp);
        try {
          PastMatch pastMatch = await _repo.getPastMatch(matchId);
          User user = await _repo.getUser();
          yield WinState.winnerDeclared(user.username, pastMatch);
        } catch (e) {
          print(e);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    if (_winnerSubs != null) _winnerSubs.cancel();
    super.dispose();
  }
}
