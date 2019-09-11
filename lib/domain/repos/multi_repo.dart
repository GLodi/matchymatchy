import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

/// MultiBloc's repository.
class MultiRepo extends GameRepo {
  final ApiProvider apiProvider;
  final MessagingEventBus messProvider;
  final SharedPrefsProvider prefsProvider;
  String lastMatchId;

  MultiRepo(this.apiProvider, this.messProvider, this.prefsProvider,
      LogicProvider logicProvider, DbProvider dbProvider)
      : super(
          logicProvider: logicProvider,
          dbProvider: dbProvider,
        );

  @override
  Future<int> getMoves() async {
    ActiveMatch activeMatch = await dbProvider.getActiveMatch(lastMatchId);
    return activeMatch.moves;
  }

  @override
  Future<void> increaseMoves() async {
    ActiveMatch activeMatch = await dbProvider.getActiveMatch(lastMatchId);
    activeMatch.moves += 1;
    return dbProvider.updateActiveMatch(activeMatch);
  }

  @override
  Future<bool> moveDone(GameField gameField, TargetField targetField) async {
    var need = logicProvider.needToSendMove(gameField, targetField);
    if (need) {
      ActiveMatch currentSituation =
          await dbProvider.getActiveMatch(lastMatchId);
      TargetField newTarget = logicProvider.diffToSend(gameField, targetField);
      String uid = await prefsProvider.getUid();
      bool isCorrect =
          await logicProvider.checkIfCorrect(gameField, targetField);
      await apiProvider.sendMove(
          currentSituation, newTarget.grid, uid, isCorrect);
    }
    return logicProvider.checkIfCorrect(gameField, targetField);
  }

  Future<bool> forfeit() async {
    var userId = await prefsProvider.getUid();
    return apiProvider.sendForfeit(userId, lastMatchId);
  }

  Future<ActiveMatch> queuePlayer() async {
    String uid = await prefsProvider.getUid();
    String token = await messProvider.getToken();
    ActiveMatch currentMatch = await apiProvider.queuePlayer(uid, token);
    lastMatchId = currentMatch.matchId;
    if (currentMatch.started == 1) {
      await dbProvider.storeActiveMatch(currentMatch);
    }
    return currentMatch;
  }
}
