import 'package:rxdart/rxdart.dart';
import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider loginProvider;
  final SharedPrefsProvider prefsProvider;

  HomeRepo(this.loginProvider, this.prefsProvider);

  Future<void> loginWithGoogle() => loginProvider
      .loginWithGoogle()
      .catchError((e) => throw e)
      .then((user) => prefsProvider.storeUser(user));

  Observable<User> checkIfLoggedIn() =>
      Observable.fromFuture(prefsProvider.getUser())
          .handleError((e) => throw e);

  Observable<bool> isFirstOpen() =>
      Observable.fromFuture(prefsProvider.isFirstOpen())
          .handleError((e) => throw e);
}
