import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

/// MultiBloc's repository.
class MultiRepo extends GameRepo {
  final ApiProvider apiProvider;
  final MessagingProvider messProvider;

  MultiRepo(this.apiProvider, this.messProvider, LogicProvider logicProvider,
      DbProvider dbProvider, SharedPrefsProvider prefsProvider)
      : super(
            logicProvider: logicProvider,
            dbProvider: dbProvider,
            prefsProvider: prefsProvider);

  @override
  Observable<bool> isCorrect(GameField gameField, TargetField targetField) {
    var need = logicProvider.needToSendMove(gameField, targetField);
    if (need) {
      var targetDiff = logicProvider.diffToSend(gameField, targetField);
      // TODO most likely wrong
      Observable.zip([
        Observable.fromFuture(prefsProvider.getCurrentGameSession()),
        Observable.fromFuture(
            logicProvider.checkIfCorrect(gameField, targetField)),
      ], (values) => apiProvider.sendMove(targetDiff, values[0], values[1]))
          .handleError((e) => throw e)
          .listen((_) => print('successfully sent move to server'));
    }
    return Observable.fromFuture(
            logicProvider.checkIfCorrect(gameField, targetField))
        .handleError((e) => throw e);
  }

  Observable<String> getStoredUid() =>
      Observable.fromFuture(prefsProvider.getUid()).handleError((e) => throw e);

  Observable<Game> queuePlayer() {
    prefsProvider.restoreMoves().then((_) {});
    return Observable.combineLatest3(
        Observable.fromFuture(prefsProvider.restoreMoves()),
        Observable.fromFuture(prefsProvider.getUid()),
        Observable.fromFuture(messProvider.getToken()),
        (_, uid, token) =>
            Observable.fromFuture(apiProvider.queuePlayer(uid, token))
                .listen((game) => game)).handleError((e) => throw e);
  }

  Observable<void> updateUserInfo() =>
      Observable.fromFuture(prefsProvider.getUid())
          .asyncMap((uid) => apiProvider.getUser(uid))
          .asyncMap((user) => prefsProvider.storeUser(user))
          .handleError((e) => throw e);

  void listenToMatchUpdates() => messProvider.listenToMatchUpdates();

  TargetField diffToSend(GameField gameField, TargetField targetField) =>
      logicProvider.diffToSend(gameField, targetField);

  Stream<ChallengeMessage> get challengeMessages =>
      messProvider.challengeMessages;

  Stream<MoveMessage> get moveMessages => messProvider.moveMessages;

  Stream<WinnerMessage> get winnerMessages => messProvider.winnerMessages;

  void storeMatchId(String matchId) => prefsProvider.storeMatchId(matchId);
}
