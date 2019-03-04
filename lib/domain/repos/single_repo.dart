import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';

class SingleRepo {
  final LogicProvider _logicHelper;

  SingleRepo(this._logicHelper);

  Observable<GameField> getGame() =>
      Observable.fromFuture(_logicHelper.getGame());

  Observable<GameField> applyMove(Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(move));

  Observable<TargetField> getTarget() =>
      Observable.fromFuture(_logicHelper.getTarget());

  Observable<bool> checkIfCorrect() =>
      Observable.fromFuture(_logicHelper.checkIfCorrect());

  Observable<int> getMovesAmount() =>
      Observable.fromFuture(_logicHelper.getMovesNumber());

}