import 'package:flutter/foundation.dart';

import 'package:matchymatchy/domain/bloc_utils/bloc_utils.dart';

class WinState extends BlocState {
  final WinStateType type;
  final String message;
  final String winner;
  final int moves;
  final int enemyMoves;

  WinState({
    @required this.type,
    this.message,
    this.winner,
    this.moves,
    this.enemyMoves,
  });

  factory WinState.waitingForOpp() =>
      WinState(type: WinStateType.waitingForOpp);

  factory WinState.winnerDeclared(String winner) =>
      WinState(type: WinStateType.winnerDeclared, winner: winner);

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

  WinEvent({this.type: WinEventType.single, this.moves, this.matchId});

  factory WinEvent.single(int moves) =>
      WinEvent(type: WinEventType.single, moves: moves);

  factory WinEvent.multi(String matchId) =>
      WinEvent(type: WinEventType.multi, matchId: matchId);
}

enum WinEventType {
  multi,
  single,
}
