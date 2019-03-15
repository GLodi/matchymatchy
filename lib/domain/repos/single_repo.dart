import 'package:rxdart/rxdart.dart';

import 'game_repo.dart';
import 'package:squazzle/data/data.dart';

class SingleRepo extends GameRepo {
  final LogicProvider _logicHelper;
  final DbProvider _dbProvider;

  SingleRepo(this._logicHelper, this._dbProvider);

  @override
  Observable<Game> getGame() => null;

  @override
  Observable<GameField> getGameField() =>
      Observable.fromFuture(_dbProvider.getGameField(1))
        .handleError((e) => throw e);

  @override
  Observable<TargetField> getTargetField() =>
      Observable.fromFuture(_dbProvider.getTargetField(1))
        .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(move))
        .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect() =>
      Observable.fromFuture(_logicHelper.checkIfCorrect())
        .handleError((e) => throw e);

  @override
  Observable<int> getMovesAmount() =>
      Observable.fromFuture(_logicHelper.getMovesNumber())
        .handleError((e) => throw e);

}