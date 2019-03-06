import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';

abstract class GameRepo {

  Observable<GameField> getGame();

  Observable<GameField> applyMove(Move move);

  Observable<TargetField> getTarget();

  Observable<bool> checkIfCorrect();

  Observable<int> getMovesAmount();

}