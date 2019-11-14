import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider _loginProvider;
  final SharedPrefsProvider _prefsProvider;
  final ApiProvider _apiProvider;
  final DbProvider _dbProvider;

  HomeRepo(this._loginProvider, this._prefsProvider, this._apiProvider,
      this._dbProvider);

  Future<void> loginWithGoogle(String fcmToken) async {
    User user = await _loginProvider.loginWithGoogle(fcmToken);
    await _prefsProvider.storeUser(user);
  }

  Future<void> logout() async {
    await _dbProvider.deleteActiveMatches();
    await _dbProvider.deletePastMatches();
    await _prefsProvider.logout();
  }

  Future<User> checkIfLoggedIn() => _prefsProvider.getUser();

  Future<bool> isFirstOpen() => _prefsProvider.isFirstOpen();

  Future<String> getUid() => _prefsProvider.getUid();

  Future<void> updateUser() => _prefsProvider
      .getUid()
      .then((uid) => _apiProvider.getUser(uid))
      .then((user) => _prefsProvider.storeUser(user));

  Future<User> getUser() => _prefsProvider.getUser();
}
