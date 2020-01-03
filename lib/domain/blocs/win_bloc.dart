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
        listenToMessages();
        yield WinState(type: WinStateType.waitingForOpp);
        try {
          PastMatch pastMatch = await _repo.getPastMatch(matchId);
        } catch (e) {
          // TODO: nothing, as waitingforopp is already showing
        }
        break;
      default:
    }
  }

  void listenToMessages() {
    if (_winnerSubs == null) {
      print('winbloc matchId: ' + matchId);
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) async {
        if (mess.matchId == matchId) {
          // TODO: make network call presuming pastmatch exists on db
          print('win winner');
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
