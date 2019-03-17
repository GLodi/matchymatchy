import 'package:rxdart/rxdart.dart';
import 'dart:math';

import 'game_repo.dart';
import 'package:squazzle/data/data.dart';

class SingleRepo extends GameRepo {
  final LogicProvider _logicHelper;
  final DbProvider _dbProvider;

  SingleRepo(this._logicHelper, this._dbProvider);

  @override
  Observable<Game> getRandomGame() => null;

  @override
  Observable<GameField> getGameField(int id) =>
      Observable.fromFuture(_dbProvider.getGameField(id))
        .handleError((e) => throw e);

  @override
  Observable<TargetField> getTargetField(int id) =>
      Observable.fromFuture(_dbProvider.getTargetField(id))
        .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(gameField, move))
        .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(GameField gameField, TargetField targetField) =>
      Observable.fromFuture(_logicHelper.checkIfCorrect(gameField, targetField))
        .handleError((e) => throw e);

}