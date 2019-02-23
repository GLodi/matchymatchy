import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';

class SquazzleManager {
  final ApiHelper _apiHelper;

  SquazzleManager(this._apiHelper);

  Observable<GameField> getGame() => Observable.fromFuture(_apiHelper.getGame());

  Observable<GameField> applyMove(Move move) =>
      Observable.fromFuture(_apiHelper.applyMove(move));
}