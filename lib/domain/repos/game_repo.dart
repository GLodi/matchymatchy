import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

/// Methods available for both Singleplayer and Multiplayer.
abstract class GameRepo {
  Observable<GameField> applyMove(GameField gameField, Move move);

  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField);
}
