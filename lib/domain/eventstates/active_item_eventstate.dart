import 'package:flutter/foundation.dart';

import 'package:matchymatchy/domain/bloc_utils/bloc_utils.dart';

class ActiveItemState extends BlocState {
  final ActiveItemStateType type;
  final String message;

  ActiveItemState({
    @required this.type,
    this.message,
  });

  factory ActiveItemState.init() =>
      ActiveItemState(type: ActiveItemStateType.init);

  factory ActiveItemState.notInit() =>
      ActiveItemState(type: ActiveItemStateType.notInit);

  factory ActiveItemState.error(String message) =>
      ActiveItemState(type: ActiveItemStateType.error, message: message);
}

enum ActiveItemStateType {
  init,
  notInit,
  error,
}

class ActiveItemEvent extends BlocEvent {
  final ActiveItemEventType type;
  final String matchId;

  ActiveItemEvent({this.type: ActiveItemEventType.start, this.matchId});

  factory ActiveItemEvent.start(String matchId) =>
      ActiveItemEvent(type: ActiveItemEventType.start, matchId: matchId);
}

enum ActiveItemEventType {
  start,
}
