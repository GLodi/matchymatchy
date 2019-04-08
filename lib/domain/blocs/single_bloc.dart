import 'dart:math';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class SingleBloc extends GameBloc {
  final SingleRepo repo;
  var ran = Random();

  // Streams extracted from GameBloc's subjects
  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  SingleBloc(this.repo) : super(repo);

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    switch (event.type) {
      case GameEventType.start:
        GameState result;
        int t = ran.nextInt(500) + 1;
        await repo
            .getGame(t)
            .handleError((e) =>
                result = GameState.error('error retrieving data from db'))
            .listen((game) {
          gameField = game.gameField;
          targetField = game.targetField;
          result = GameState.init();
        }).asFuture();
        yield result;
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        // TODO handle victory
        break;
      default:
    }
  }
}
