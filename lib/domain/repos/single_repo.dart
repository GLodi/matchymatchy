import 'package:rxdart/rxdart.dart';

import 'game_repo.dart';
import 'package:squazzle/data/data.dart';

class SingleRepo extends GameRepo {
  final LogicProvider _logicHelper;

  SingleRepo(this._logicHelper);

  @override
  Observable<GameField> getGame() =>
      Observable.fromFuture(_logicHelper.getGame());

  @override
  Observable<GameField> applyMove(Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(move));

  @override
  Observable<TargetField> getTarget() =>
      Observable.fromFuture(_logicHelper.getTarget());

  @override
  Observable<bool> checkIfCorrect() =>
      Observable.fromFuture(_logicHelper.checkIfCorrect());

  @override
  Observable<int> getMovesAmount() =>
      Observable.fromFuture(_logicHelper.getMovesNumber());

}