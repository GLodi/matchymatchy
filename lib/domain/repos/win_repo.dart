import 'package:matchymatchy/data/data.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinRepo {
  final SharedPrefsProvider _prefsProvider;

  WinRepo(this._prefsProvider);

  Future<User> getUser() async => await _prefsProvider.getUser();
}
