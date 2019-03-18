import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class SquazzleState extends BlocState {
  final SquazzleStateType type;
  final String message;

  SquazzleState({
    @required this.type,
    this.message,
  });

  factory SquazzleState.init() =>
      SquazzleState(type: SquazzleStateType.init);

  factory SquazzleState.notInit() =>
      SquazzleState(type: SquazzleStateType.notInit);

  factory SquazzleState.error(String message) =>
      SquazzleState(type: SquazzleStateType.error, message: message);
}

enum SquazzleStateType {
  init,
  notInit,
  error,
}

class SquazzleEvent extends BlocEvent {
  final SquazzleEventType type;

  SquazzleEvent({
    this.type : SquazzleEventType.start
  }) : assert(type != null);
}

enum SquazzleEventType {
  start,
  error,
  victory,
}