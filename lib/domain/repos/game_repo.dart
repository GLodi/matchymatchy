import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

/// Methods available for both Singleplayer and Multiplayer.
abstract class GameRepo {
  // Apply chosen move and return new field
  Observable<GameField> applyMove(GameField gameField, Move move);

  // Check whether player has reached end game
  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField);

  // Return amount of moves currently played
  Observable<int> getMoves();
}
