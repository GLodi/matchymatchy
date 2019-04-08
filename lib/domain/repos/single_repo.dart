import 'package:rxdart/rxdart.dart';

import 'game_repo.dart';
import 'package:squazzle/data/data.dart';

/// SingleBloc's repository.
class SingleRepo extends GameRepo {
  final LogicProvider _logicHelper;
  final DbProvider _dbProvider;

  SingleRepo(this._logicHelper, this._dbProvider);

  @override
  Observable<Game> getGame(int id) =>
      Observable.fromFuture(_dbProvider.getGame(id))
          .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(gameField, move))
          .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(
          GameField gameField, TargetField targetField) =>
      Observable.fromFuture(_logicHelper.checkIfCorrect(gameField, targetField))
          .handleError((e) => throw e);
}
