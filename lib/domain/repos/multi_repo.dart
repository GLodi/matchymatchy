import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiRepo;
  final LogicProvider _logicProvider;

  MultiRepo(this._logicProvider, this._apiRepo);

  @override
  Observable<Game> getGame(int id) =>
      Observable.fromFuture(_apiRepo.getGame(id))
        .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) => 
      //Observable.fromFuture(_logicProvider.applyMove(gameField, move))
      //  .flatMap((gf) {});
      Observable.concat([
        Observable.fromFuture(_logicProvider.applyMove(gameField, move)),
        // send move to server
      ]).handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField) => 
      Observable.fromFuture(_logicProvider.checkIfCorrect(gameField, targetField))
        .handleError((e) => throw e);

}