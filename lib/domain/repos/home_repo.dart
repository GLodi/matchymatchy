import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider loginProvider;
  final SharedPrefsProvider prefsProvider;
  final DbProvider dbProvider;

  HomeRepo(this.loginProvider, this.prefsProvider, this.dbProvider);

  Future<void> loginWithGoogle() => loginProvider
      .loginWithGoogle()
      .then((user) => prefsProvider.storeUser(user));

  Future<User> checkIfLoggedIn() => prefsProvider.getUser();

  Future<void> storeMatchOnline(MatchOnline matchOnline) =>
      dbProvider.storeMatchOnline(matchOnline);

  Future<List<MatchOnline>> getMatches() => dbProvider.getAllMatchOnline();

  Future<bool> isFirstOpen() => prefsProvider.isFirstOpen();
}
