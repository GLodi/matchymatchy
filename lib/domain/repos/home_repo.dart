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

  Future<bool> isFirstOpen() => prefsProvider.isFirstOpen();

  Future<String> getUid() => prefsProvider.getUid();

  Future<void> updateUser() => prefsProvider
      .getUid()
      .then((uid) => apiProvider.getUser(uid))
      .then((user) => prefsProvider.storeUser(user));

  Future<User> getUser() => prefsProvider.getUser();

  Future<void> updateMatches() async {
    String uid = await prefsProvider.getUid();
    List activeMatches = await apiProvider.getActiveMatches(uid);
    if (activeMatches.isNotEmpty)
      await dbProvider.storeActiveMatches(activeMatches);
    List pastMatches = await apiProvider.getPastMatches(uid);
    if (pastMatches.isNotEmpty) await dbProvider.storePastMatches(pastMatches);
  }
}
