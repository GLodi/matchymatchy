import 'package:matchymatchy/data/data.dart';

class ActiveMatchItemRepo {
  final DbProvider _dbProvider;

  ActiveMatchItemRepo(this._dbProvider);

  Future<void> updateActiveMatchOnEnemyMove(int moves, String matchId) async {
    ActiveMatch match = await _dbProvider.getActiveMatch(matchId);
    match.enemyMoves = moves;
    await _dbProvider.updateActiveMatch(match);
  }

  Future<int> getActiveMatchPlayerMove(String matchId) async {
    ActiveMatch match = await _dbProvider.getActiveMatch(matchId);
    return match.moves;
  }
}
