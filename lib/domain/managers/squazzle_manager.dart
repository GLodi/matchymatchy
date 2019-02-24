import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';

class SquazzleManager {
  final ApiHelper _apiHelper;
  final LogicHelper _logicHelper;

  SquazzleManager(this._apiHelper, this._logicHelper);

  Observable<GameField> getGame() =>
      Observable.fromFuture(_logicHelper.getGame());

  Observable<GameField> applyMove(Move move) =>
      Observable.fromFuture(_logicHelper.applyMove(move));

  Observable<TargetField> getTarget() =>
      Observable.fromFuture(_logicHelper.getTarget());
}