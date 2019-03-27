import 'package:rxdart/rxdart.dart';

import 'game_manager.dart';
import 'package:squazzle/data/data.dart';

class SingleManager extends GameManager {
  final LogicRepo _logicHelper;
  final DbRepo _dbProvider;

  SingleManager(this._logicHelper, this._dbProvider);

  @override
  Observable<Game> getGame(int id) =>
      Observable.fromFuture(_dbProvider.getGame(id))
          .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(gameField, move))
          // TODO save to db after checking move legality
          .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(
          GameField gameField, TargetField targetField) =>
      Observable.fromFuture(_logicHelper.checkIfCorrect(gameField, targetField))
          .handleError((e) => throw e);
}
