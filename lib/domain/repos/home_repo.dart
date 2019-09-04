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
    return await prefsProvider.storeUser(user);
  }

  Future<User> checkIfLoggedIn() => prefsProvider.getUser();

  Future<List<ActiveMatch>> getActiveMatches() => dbProvider.getActiveMatches();

  Future<List<PastMatch>> getPastMatches() => dbProvider.getPastMatches();

  Future<bool> isFirstOpen() => prefsProvider.isFirstOpen();

  Future<String> getUid() => prefsProvider.getUid();

  Future<void> updateUserInfo() => prefsProvider
      .getUid()
      .then((uid) => apiProvider.getUser(uid))
      .then((user) => prefsProvider.storeUser(user));

  Future<void> updateMatches() async {
    String uid = await prefsProvider.getUid();
    await dbProvider
        .storeActiveMatches(await apiProvider.getActiveMatches(uid));
    await dbProvider.storePastMatches(await apiProvider.getPastMatches(uid));
  }
}
