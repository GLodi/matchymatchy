import 'package:matchymatchy/data/data.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinRepo {
  final SharedPrefsProvider _prefsProvider;
  final DbProvider _dbProvider;

  WinRepo(this._prefsProvider, this._dbProvider);

  Future<User> getUser() async => await _prefsProvider.getUser();

  Future<ActiveMatch> getActiveMatch(String matchId) async =>
      await _dbProvider.getActiveMatch(matchId);
}
