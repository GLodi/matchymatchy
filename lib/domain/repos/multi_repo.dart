import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiProvider;
  final LogicProvider _logicProvider;
  final SharedPrefsProvider _prefsProvider;

  MultiRepo(this._logicProvider, this._apiProvider, this._prefsProvider);

  @override
  Observable<Game> getGame(int id) =>
      Observable.fromFuture(_apiProvider.getGame(id))
          .handleError((e) => throw e);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(_logicProvider.applyMove(gameField, move))
          .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(
          GameField gameField, TargetField targetField) =>
      Observable.fromFuture(
              _logicProvider.checkIfCorrect(gameField, targetField))
          .handleError((e) => throw e);

  Observable<String> getStoredUid() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .handleError((e) => throw e);

  Observable<String> queuePlayer(String uid) =>
      Observable.fromFuture(_apiProvider.queuePlayer(uid))
          .handleError((e) => throw e);

  Observable<MatchUpdate> listenToMatchUpdates(String matchId) =>
      Observable.fromFuture(_apiProvider.listenToMatchUpdates(matchId))
          .handleError((e) => throw e);
}
