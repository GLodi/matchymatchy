import 'game_repo.dart';
import 'package:matchymatchy/data/data.dart';

/// SingleBloc's repository.
class SingleRepo extends GameRepo {
  int moves = 0;

  SingleRepo(
    LogicProvider logicProvider,
    DbProvider dbProvider,
  ) : super(
          logicProvider: logicProvider,
          dbProvider: dbProvider,
        );

  @override
  Future<int> getMoves() {
    return Future.value(moves);
  }

  @override
  Future<void> increaseMoves() {
    moves += 1;
    return null;
  }

  @override
  Future<bool> moveDone(GameField gameField, TargetField targetField) =>
      logicProvider.checkIfCorrect(gameField, targetField);

  Future<Match> getTestMatch(int id) {
    moves = 0;
    return dbProvider.getTestMatch(id);
  }
}
