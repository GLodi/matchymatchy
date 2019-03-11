import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiRepo;
  LogicProvider _logicHelper;

  MultiRepo(this._apiRepo);

  @override
  Observable<GameField> getGame() =>
      Observable.fromFuture(_apiRepo.getDb());

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