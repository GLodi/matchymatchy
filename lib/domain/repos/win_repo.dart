import 'package:matchymatchy/data/data.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinRepo {
  DbProvider _dbProvider;

  WinRepo(this._dbProvider);

  Future<PastMatch> getPastMatch(String matchId) async =>
      await _dbProvider.getPastMatch(matchId);
}
