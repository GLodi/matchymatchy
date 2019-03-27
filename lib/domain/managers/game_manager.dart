import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

abstract class GameManager {
  Observable<Game> getGame(int id);

  Observable<GameField> applyMove(GameField gameField, Move move);

  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField);
}
