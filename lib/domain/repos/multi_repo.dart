import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiProvider;
  final LogicProvider _logicProvider;
  final SharedPreferencesProvider _prefsProvider;

  MultiRepo(this._logicProvider, this._apiProvider, this._prefsProvider);

  @override
  Observable<Game> getGame(int id) =>
      Observable.fromFuture(_apiProvider.getGame(id))
          .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.concat([
        Observable.fromFuture(_logicProvider.applyMove(gameField, move)),
        // send move to server
      ]).handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(
          GameField gameField, TargetField targetField) =>
      Observable.fromFuture(
              _logicProvider.checkIfCorrect(gameField, targetField))
          .handleError((e) => throw e);

  Observable<void> queuePlayer(int gfid, String matchId) {
    return Observable.fromFuture(_prefsProvider.getUid())
        .map((uid) => _apiProvider.queuePlayer(uid, gfid, matchId))
        .handleError((e) => throw e);
  }
}
