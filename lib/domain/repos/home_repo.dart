import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider _loginProvider;
  final SharedPrefsProvider _prefsProvider;
  final DbProvider _dbProvider;
  final ApiProvider _apiProvider;

  HomeRepo(this._loginProvider, this._prefsProvider, this._dbProvider,
      this._apiProvider);

  Future<void> loginWithGoogle() async {
    User user = await _loginProvider.loginWithGoogle();
    return await _prefsProvider.storeUser(user);
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
