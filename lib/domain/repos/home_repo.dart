import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider loginProvider;
  final SharedPrefsProvider prefsProvider;

  HomeRepo(this.loginProvider, this.prefsProvider);

  Future<void> loginWithGoogle() => loginProvider
      .loginWithGoogle()
      .then((user) => prefsProvider.storeUser(user));

  Future<User> checkIfLoggedIn() => prefsProvider.getUser();

  Future<bool> isFirstOpen() => prefsProvider.isFirstOpen();
}
