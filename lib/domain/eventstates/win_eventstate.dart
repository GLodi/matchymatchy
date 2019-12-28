import 'package:flutter/foundation.dart';

import 'package:matchymatchy/domain/bloc_utils/bloc_utils.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinState extends BlocState {
  final WinStateType type;
  final String message;
  final String winner;
  final String username;
  final int moves;
  final ActiveMatch activeMatch;

  WinState({
    @required this.type,
    this.message,
    this.winner,
    this.moves,
    this.username,
    this.activeMatch,
  });

  factory WinState.waitingForOpp() =>
      WinState(type: WinStateType.waitingForOpp);

  factory WinState.winnerDeclared(
          String winner, String username, ActiveMatch activeMatch) =>
      WinState(
        type: WinStateType.winnerDeclared,
        winner: winner,
        username: username,
        activeMatch: activeMatch,
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
  final String winner;
  final String username;
  final int moves;
  final ActiveMatch activeMatch;

  WinEvent({
    this.type: WinEventType.single,
    this.matchId,
    this.winner,
    this.username,
    this.moves,
    this.activeMatch,
  });

  factory WinEvent.single(int moves) =>
      WinEvent(type: WinEventType.single, moves: moves);

  factory WinEvent.multi(String matchId) =>
      WinEvent(type: WinEventType.multi, matchId: matchId);

  factory WinEvent.showWinner(
          String winner, String username, ActiveMatch activeMatch) =>
      WinEvent(
        type: WinEventType.showWinner,
        winner: winner,
        username: username,
        activeMatch: activeMatch,
      );
}

enum WinEventType {
  showWinner,
  multi,
  single,
}
