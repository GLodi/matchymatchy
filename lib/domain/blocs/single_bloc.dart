import 'dart:math';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class SingleBloc extends GameBloc {
  final SingleRepo _repo;
  Random ran = Random();

  Stream<int> get moveNumber => moveNumberSubject.stream;
  Stream<void> get intentToWinScreen => intentToWinScreenSubject.stream;

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
      default:
    }
  }

  @override
  void winCheck(GameField gf, TargetField tf) async {
    bool isCorrect = await _repo.moveDone(gf, tf);
    if (isCorrect) intentToWinScreenSubject.add(null);
  }
}
