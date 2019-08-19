import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

/// MultiBloc's repository.
class MultiRepo extends GameRepo {
  final ApiProvider apiProvider;
  final MessagingEventBus messProvider;

  MultiRepo(this.apiProvider, this.messProvider, LogicProvider logicProvider,
      DbProvider dbProvider, SharedPrefsProvider prefsProvider)
      : super(
            logicProvider: logicProvider,
            dbProvider: dbProvider,
            prefsProvider: prefsProvider);

  @override
  Future<bool> moveDone(GameField gameField, TargetField targetField) async {
    var need = logicProvider.needToSendMove(gameField, targetField);
    if (need) {
      await prefsProvider.storeGf(gameField);
      await prefsProvider
          .storeTarget(logicProvider.diffToSend(gameField, targetField));
      Session session = await prefsProvider.getCurrentSession();
      bool isCorrect =
          await logicProvider.checkIfCorrect(gameField, targetField);
      await apiProvider.sendMove(session, isCorrect);
    }
    return logicProvider.checkIfCorrect(gameField, targetField);
  }

  Future<bool> forfeit() async {
    var userId = await prefsProvider.getUid();
    var matchId = await prefsProvider.getMatchId();
    return apiProvider.sendForfeit(userId, matchId);
  }

  Future<MatchOnline> queuePlayer() async {
    await prefsProvider.restoreMoves();
    String uid = await prefsProvider.getUid();
    String token = await messProvider.getToken();
    MatchOnline situation = await apiProvider.queuePlayer(uid, token);
    prefsProvider.storeMoves(situation.moves);
    prefsProvider.storeMatchId(situation.matchId);
    dbProvider.storeMatchOnline(situation);
    return situation;
  }

  void storeMatchId(String matchId) => prefsProvider.storeMatchId(matchId);
}
