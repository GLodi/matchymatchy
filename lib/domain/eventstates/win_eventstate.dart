import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class WinState extends BlocState {
  final WinStateType type;
  final String message;

  WinState({
    @required this.type,
    this.message,
  });

  factory WinState.waitingForOpp() =>
      WinState(type: WinStateType.waitingForOpp);

  factory WinState.winnerDeclared() =>
      WinState(type: WinStateType.winnerDeclared);
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
