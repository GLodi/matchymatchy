import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_manager.dart';

class MultiManager extends GameManager {
  final ApiRepo _apiProvider;
  final LogicRepo _logicProvider;
  final SharedPrefsRepo _prefsProvider;

  MultiManager(this._logicProvider, this._apiProvider, this._prefsProvider);

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

  Observable<String> getStoredUid() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .handleError((e) => throw e);

  Observable<void> queuePlayer(String uid) =>
      Observable.fromFuture(_apiProvider.queuePlayer(uid))
          .handleError((e) => throw e);
}
