import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiRepo;

  MultiRepo(this._apiRepo);

  @override
  Observable<Game> getGame(int id) =>
      Observable.fromFuture(_apiRepo.getGame(id));

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) => null;

  @override
  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField) => null;

}