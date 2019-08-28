import 'dart:math';

import 'package:squazzle/domain/domain.dart';

class SingleBloc extends GameBloc {
  final SingleRepo _repo;
  Random ran = Random();

  // Streams extracted from GameBloc's subjects
  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  SingleBloc(this._repo) : super(_repo);

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    switch (event.type) {
      case GameEventType.start:
        GameState result;
        int t = ran.nextInt(500) + 1;
        await _repo
            .getTestMatch(t)
            .catchError((e) =>
                result = GameState.error('error retrieving data from db'))
            .then((game) {
          gameField = game.gameField;
          targetField = game.targetField;
          result = GameState.init();
        });
        yield result;
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        // TODO: handle victory
        break;
      default:
    }
  }
}
