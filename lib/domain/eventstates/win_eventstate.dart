import 'package:flutter/foundation.dart';

import 'package:matchymatchy/domain/bloc_utils/bloc_utils.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinState extends BlocState {
  final WinStateType type;
  final String message;
  final String username;
  final int moves;
  final PastMatch pastMatch;

  WinState({
    @required this.type,
    this.message,
    this.moves,
    this.username,
    this.pastMatch,
  });

  factory WinState.waitingForOpp() =>
      WinState(type: WinStateType.waitingForOpp);

  factory WinState.winnerDeclared(String username, PastMatch pastMatch) =>
      WinState(
        type: WinStateType.winnerDeclared,
        username: username,
        pastMatch: pastMatch,
      );

  factory WinState.singleWin(int moves) =>
      WinState(type: WinStateType.singleWin, moves: moves);
}

enum WinStateType {
  waitingForOpp,
  winnerDeclared,
  singleWin,
}

class WinEvent extends BlocEvent {
  final WinEventType type;
  final String matchId;
  final int moves;

  WinEvent({
    this.type: WinEventType.single,
    this.matchId,
    this.moves,
  });

  factory WinEvent.single(int moves) =>
      WinEvent(type: WinEventType.single, moves: moves);

  factory WinEvent.multi(String matchId) =>
      WinEvent(type: WinEventType.multi, matchId: matchId);
}

enum WinEventType {
  multi,
  single,
}
