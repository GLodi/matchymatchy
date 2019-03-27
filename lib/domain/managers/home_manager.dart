import 'package:rxdart/rxdart.dart';
import 'package:squazzle/data/data.dart';

class HomeManager {
  final LoginRepo _loginProvider;
  final SharedPrefsRepo _preferencesProvider;

  HomeManager(this._loginProvider, this._preferencesProvider);

  Observable<void> loginWithGoogle() =>
      Observable.fromFuture(_loginProvider.loginWithGoogle()).map((user) {
        _preferencesProvider.storeUser(
            user.displayName, user.uid, user.photoUrl);
      }).handleError((e) => throw e);

  Observable<User> checkIfLoggedIn() =>
      Observable.fromFuture(_preferencesProvider.getUser())
          .handleError((e) => throw e);
}
