import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

/// MultiBloc's repository.
class MultiRepo extends GameRepo {
  String _matchId; // TODO store this in db
  // TODO also store moves
  final ApiProvider _apiProvider;
  final LogicProvider _logicProvider;
  final SharedPrefsProvider _prefsProvider;

  MultiRepo(this._logicProvider, this._apiProvider, this._prefsProvider);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(_logicProvider.applyMove(gameField, move))
          .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(
      GameField gameField, TargetField targetField) {
    var need = _logicProvider.needToSendMove(gameField, targetField);
    if (need) {
      var targetDiff = _logicProvider.diffToSend(gameField, targetField);
      Observable.fromFuture(_prefsProvider.getUid())
          .asyncMap(
              (uid) => _apiProvider.sendNewTarget(targetDiff, uid, _matchId))
          .handleError((e) => throw e)
          .listen((_) {});
    }
    return Observable.fromFuture(
            _logicProvider.checkIfCorrect(gameField, targetField))
        .handleError((e) => throw e);
  }

  Observable<bool> sendWinSignal(int moves) =>
      Observable.fromFuture(_prefsProvider.getUid())
          .asyncMap((uid) => _apiProvider.sendWinSignal(uid, _matchId, moves))
          .handleError((e) => throw e);

  Observable<String> getStoredUid() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .handleError((e) => throw e);

  Observable<Game> queuePlayer(String token) =>
      Observable.fromFuture(_prefsProvider.getUid())
          .asyncMap((uid) => _apiProvider.queuePlayer(uid, token))
          .handleError((e) => throw e);

  Observable<void> updateUserInfo() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .asyncMap((uid) => _apiProvider.getUser(uid))
          .map((user) => _prefsProvider.storeUser(user))
          .handleError((e) => throw e);

  TargetField diffToSend(GameField gameField, TargetField targetField) =>
      _logicProvider.diffToSend(gameField, targetField);

  void setMatchId(String matchId) => _matchId = matchId;
}
