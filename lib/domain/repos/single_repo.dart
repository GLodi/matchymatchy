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
      Observable.fromFuture(_logicHelper.getGame());

  @override
  Observable<TargetField> getTargetField() =>
      Observable.fromFuture(_logicHelper.getTarget());

  @override
  Observable<GameField> applyMove(Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(move));

  @override
  Observable<bool> checkIfCorrect() =>
      Observable.fromFuture(_logicHelper.checkIfCorrect());

  @override
  Observable<int> getMovesAmount() =>
      Observable.fromFuture(_logicHelper.getMovesNumber());

}