import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

/// MultiBloc's repository.
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
      // TODO needToSend doesn't work correctly
      Observable.fromFuture(_logicProvider.needToSendMove(gameField))
          .asyncMap(
              (boolean) => _logicProvider.diffToSend(gameField, targetField))
          .zipWith(_prefsProvider.getUid().asStream(),
              (target, uid) => _apiProvider.sendNewTarget(target, uid))
          .asyncMap((boolean) =>
              _logicProvider.checkIfCorrect(gameField, targetField))
          .handleError((e) => throw e);

  Observable<String> getStoredUid() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .handleError((e) => throw e);

  Observable<Game> queuePlayer(String uid, String token) =>
      Observable.fromFuture(_apiProvider.queuePlayer(uid, token))
          .handleError((e) => throw e);

  Observable<TargetField> diffToSend(
          GameField gameField, TargetField targetField) =>
      Observable.fromFuture(_logicProvider.diffToSend(gameField, targetField))
          .handleError((e) => throw e);

  void setMatchId(String matchId) => _apiProvider.setMatchId(matchId);
}
