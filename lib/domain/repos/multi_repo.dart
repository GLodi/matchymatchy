import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiRepo;

  MultiRepo(this._apiRepo);

  @override
  Observable<Game> getRandomGame() => null;

  @override
  Observable<GameField> getGameField(int id) =>
      Observable.fromFuture(_apiRepo.getRandomGameField());

  @override
  Observable<TargetField> getTargetField(int id) => null;

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) => null;

  @override
  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField) => null;

}