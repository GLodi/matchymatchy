import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

abstract class GameRepo {

  Observable<GameField> getGameField();

  Observable<TargetField> getTargetField();

  Observable<GameField> applyMove(GameField gameField, Move move);

  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField);

}