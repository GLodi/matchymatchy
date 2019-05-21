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
  Future<bool> isCorrect(GameField gameField, TargetField targetField) async {
    var need = logicProvider.needToSendMove(gameField, targetField);
    if (need) {
      TargetField targetDiff = logicProvider.diffToSend(gameField, targetField);
      Session session = await prefsProvider.getCurrentGameSession();
      bool isCorrect =
          await logicProvider.checkIfCorrect(gameField, targetField);
      await apiProvider.sendMove(targetDiff, session, isCorrect);
    }
    return logicProvider.checkIfCorrect(gameField, targetField);
  }

  Future<String> getStoredUid() => prefsProvider.getUid();

  Future<Game> queuePlayer() async {
    await prefsProvider.restoreMoves();
    String uid = await prefsProvider.getUid();
    String token = await messProvider.getToken();
    return await apiProvider.queuePlayer(uid, token);
  }

  Future<void> updateUserInfo() => prefsProvider
      .getUid()
      .then((uid) => apiProvider.getUser(uid))
      .then((user) => prefsProvider.storeUser(user));

  void listenToMatchUpdates() => messProvider.listenToMatchUpdates();

  void deleteInstance() => messProvider.deleteInstance();

  void storeMatchId(String matchId) => prefsProvider.storeMatchId(matchId);

  TargetField diffToSend(GameField gameField, TargetField targetField) =>
      logicProvider.diffToSend(gameField, targetField);

  Stream<ChallengeMessage> get challengeMessages =>
      messProvider.challengeMessages;

  Stream<MoveMessage> get moveMessages => messProvider.moveMessages;

  Stream<WinnerMessage> get winnerMessages => messProvider.winnerMessages;
}
