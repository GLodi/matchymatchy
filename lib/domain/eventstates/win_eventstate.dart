import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class WinState extends BlocState {
  final WinStateType type;
  final String message;
  String winner;

  WinState({
    @required this.type,
    this.message,
    this.winner,
  });

  factory WinState.waitingForOpp() =>
      WinState(type: WinStateType.waitingForOpp);

  factory WinState.winnerDeclared(String winner) =>
      WinState(type: WinStateType.winnerDeclared, winner: winner);
}

enum WinStateType {
  waitingForOpp,
  winnerDeclared,
}

class WinEvent extends BlocEvent {
  final WinEventType type;

  WinEvent({this.type: WinEventType.start});
}

enum WinEventType {
  start,
}
