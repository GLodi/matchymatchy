import 'package:matchymatchy/data/data.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinRepo {
  SharedPrefsProvider _prefsProvider;
  DbProvider _dbProvider;

  WinRepo(this._dbProvider);

  Future<PastMatch> getPastMatch(String matchId) async =>
      await _dbProvider.getPastMatch(matchId);

  Future<User> getUser() async => await _prefsProvider.getUser();
}
