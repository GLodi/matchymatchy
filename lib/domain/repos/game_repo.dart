import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

abstract class GameRepo {

  Observable<Game> getGame();
  
  Observable<GameField> getGameField();

  Observable<TargetField> getTargetField();

  Observable<GameField> applyMove(Move move);

  Observable<bool> checkIfCorrect();

  Observable<int> getMovesAmount();

}