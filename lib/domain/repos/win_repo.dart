import 'package:matchymatchy/data/data.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinRepo {
  ApiProvider _apiProvider;
  SharedPrefsProvider _prefsProvider;

  WinRepo(this._apiProvider, this._prefsProvider);

  Future<PastMatch> getPastMatch(String matchId) async {
    String uid = await _prefsProvider.getUid();
    return await _apiProvider.getPastMatch(uid, matchId);
  }
}
