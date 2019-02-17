import 'package:flutter/foundation.dart';

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class SquazzleState extends BlocState {
  final SquazzleStateType type;
  final String message;
  final GameField field;

  SquazzleState({
    @required this.type,
    this.message,
    this.field,
  });

  factory SquazzleState.init(GameField field) =>
      SquazzleState(type: SquazzleStateType.init,
                    field: field);

  factory SquazzleState.notInit() =>
      SquazzleState(type: SquazzleStateType.notInit);

  factory SquazzleState.error() =>
      SquazzleState(type: SquazzleStateType.error);
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
}