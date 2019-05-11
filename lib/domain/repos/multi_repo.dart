import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

/// MultiBloc's repository.
class MultiRepo extends GameRepo {
  final ApiProvider _apiProvider;
  final LogicProvider _logicProvider;
  final SharedPrefsProvider _prefsProvider;
  final MessagingProvider _messagingProvider;

  MultiRepo(this._logicProvider, this._apiProvider, this._prefsProvider,
      this._messagingProvider);

  @override
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(_logicProvider.applyMove(gameField, move))
          .asyncMap((gf) => _prefsProvider.increaseMoves())
          .handleError((e) => throw e);

  @override
  Observable<bool> checkIfCorrect(
      GameField gameField, TargetField targetField) {
    var need = _logicProvider.needToSendMove(gameField, targetField);
    if (need) {
      var targetDiff = _logicProvider.diffToSend(gameField, targetField);
      Observable.fromFuture(_prefsProvider.getUid())
          .zipWith(Observable.fromFuture(_prefsProvider.getMatchId()),
              (uid, matchId) {
            _apiProvider.sendNewTarget(targetDiff, uid, matchId);
          })
          .handleError((e) => throw e)
          .listen((_) => print('successfully sent move to server'));
    }
    return Observable.fromFuture(
            _logicProvider.checkIfCorrect(gameField, targetField))
        .handleError((e) => throw e);
  }

  @override
  Observable<int> getMoves() => Observable.fromFuture(_prefsProvider.getMoves())
      .handleError((e) => throw e);

  Observable<bool> sendWinSignal() => Observable.zip([
        Observable.fromFuture(_prefsProvider.getUid()),
        Observable.fromFuture(_prefsProvider.getMatchId()),
        Observable.fromFuture(_prefsProvider.getMoves()),
      ], (values) {
        _apiProvider.sendWinSignal(values[0], values[1], values[2]);
      }).handleError((e) => throw e);

  Observable<String> getStoredUid() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .handleError((e) => throw e);

  Observable<Game> queuePlayer() =>
      Observable.fromFuture(_prefsProvider.getUid()).zipWith(
          Observable.fromFuture(_messagingProvider.getToken()), (uid, token) {
        _apiProvider.queuePlayer(uid, token);
      }).handleError((e) => throw e);

  Observable<void> updateUserInfo() =>
      Observable.fromFuture(_prefsProvider.getUid())
          .asyncMap((uid) => _apiProvider.getUser(uid))
          .map((user) => _prefsProvider.storeUser(user))
          .handleError((e) => throw e);

  void listenToMatchUpdates() => _messagingProvider.listenToMatchUpdates();

  TargetField diffToSend(GameField gameField, TargetField targetField) =>
      _logicProvider.diffToSend(gameField, targetField);

  Stream<ChallengeMessage> get challengeMessages =>
      _messagingProvider.challengeMessages;

  Stream<MoveMessage> get moveMessages => _messagingProvider.moveMessages;

  Stream<WinnerMessage> get winnerMessages => _messagingProvider.winnerMessages;

  void storeMatchId(String matchId) => _prefsProvider.storeMatchId(matchId);
}
