import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class GameState extends BlocState {
  final GameStateType type;
  final String message;

  GameState({
    @required this.type,
    this.message,
  });

  factory GameState.init() => GameState(type: GameStateType.init);

  factory GameState.notInit() => GameState(type: GameStateType.notInit);

  factory GameState.error(String message) =>
      GameState(type: GameStateType.error, message: message);
}

enum GameStateType {
  init,
  notInit,
  error,
}

class GameEvent extends BlocEvent {
  final GameEventType type;
  final String connectMatchId;

  GameEvent({this.type: GameEventType.start, this.connectMatchId});

  factory GameEvent.start() => GameEvent(type: GameEventType.start);
  factory GameEvent.queue() => GameEvent(type: GameEventType.queue);
  factory GameEvent.connect(String connectMatchId) =>
      GameEvent(type: GameEventType.connect, connectMatchId: connectMatchId);
  factory GameEvent.matchNotFound() =>
      GameEvent(type: GameEventType.matchNotFound);
  factory GameEvent.error() => GameEvent(type: GameEventType.error);
}

enum GameEventType {
  start,
  queue,
  connect,
  matchNotFound,
  error,
}
