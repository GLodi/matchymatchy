import 'package:squazzle/data/data.dart';

class HomePageViewListRepo {
  final DbProvider _dbProvider;
  final SharedPrefsProvider _prefsProvider;
  final ApiProvider _apiProvider;

  HomePageViewListRepo(
      this._dbProvider, this._prefsProvider, this._apiProvider);

  Future<void> updateMatches() async {
    String uid = await _prefsProvider.getUid();
    List activeMatches = await _apiProvider.getActiveMatches(uid);
    await _dbProvider.deleteActiveMatches();
    await _dbProvider.storeActiveMatches(activeMatches);
    List pastMatches = await _apiProvider.getPastMatches(uid);
    await _dbProvider.storePastMatches(pastMatches);
  }

  Future<List<ActiveMatch>> getActiveMatches() async =>
      await _dbProvider.getActiveMatches();

  Future<List<PastMatch>> getPastMatches() async =>
      await _dbProvider.getPastMatches();
}
