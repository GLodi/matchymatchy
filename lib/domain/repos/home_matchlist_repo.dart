import 'package:squazzle/data/data.dart';

class HomeMatchListRepo {
  final DbProvider _dbProvider;
  final SharedPrefsProvider _prefsProvider;
  final ApiProvider _apiProvider;

  HomeMatchListRepo(this._dbProvider, this._prefsProvider, this._apiProvider);

  Future<void> updateActiveMatches() async {
    String uid = await _prefsProvider.getUid();
    List<ActiveMatch> activeMatches = await _apiProvider.getActiveMatches(uid);
    activeMatches.sort((a, b) => b.time.compareTo(a.time));
    await _dbProvider.deleteActiveMatches();
    await _dbProvider.storeActiveMatches(activeMatches);
  }

  Future<void> updatePastMatches() async {
    String uid = await _prefsProvider.getUid();
    List<PastMatch> pastMatches = await _apiProvider.getPastMatches(uid);
    pastMatches.sort((a, b) => b.time.compareTo(a.time));
    await _dbProvider.storePastMatches(pastMatches);
  }

  Future<void> updateActiveMatchMove(int moves, String matchId) async {
    ActiveMatch match = await _dbProvider.getActiveMatch(matchId);
    match.enemyMoves = moves;
    await _dbProvider.updateActiveMatch(match);
  }

  Future<List<ActiveMatch>> getActiveMatches() async =>
      await _dbProvider.getActiveMatches();

  Future<List<PastMatch>> getPastMatches() async =>
      await _dbProvider.getPastMatches();

  Future<void> deleteActiveMatch(String matchId) async =>
      await _dbProvider.deleteActiveMatch(matchId);

  Future<User> getUser() async => await _prefsProvider.getUser();
}
