import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider loginProvider;
  final SharedPrefsProvider prefsProvider;
  final DbProvider dbProvider;
  final ApiProvider apiProvider;

  HomeRepo(this.loginProvider, this.prefsProvider, this.dbProvider,
      this.apiProvider);

  Future<void> loginWithGoogle() async {
    User user = await loginProvider.loginWithGoogle();
    await dbProvider
        .storeMatchOnlineList(await apiProvider.getMatchHistory(user.uid));
    return await prefsProvider.storeUser(user);
  }

  Future<User> checkIfLoggedIn() => prefsProvider.getUser();

  Future<List<MatchOnline>> getStoredMatches() => dbProvider.getStoredMatches();

  Future<bool> isFirstOpen() => prefsProvider.isFirstOpen();

  Future<String> getStoredUid() => prefsProvider.getUid();

  Future<void> updateUserInfo() => prefsProvider
      .getUid()
      .then((uid) => apiProvider.getUser(uid))
      .then((user) => prefsProvider.storeUser(user));
}
