import 'package:rxdart/rxdart.dart';
import 'package:squazzle/data/data.dart';

/// HomeBloc's repository.
class HomeRepo {
  final LoginProvider loginProvider;
  final SharedPrefsProvider prefsProvider;

  HomeRepo(this.loginProvider, this.prefsProvider);

  Observable<void> loginWithGoogle() =>
      Observable.fromFuture(loginProvider.loginWithGoogle())
          .map((user) => prefsProvider.storeUser(user))
          .handleError((e) => throw e);

  Observable<User> checkIfLoggedIn() =>
      Observable.fromFuture(prefsProvider.getUser())
          .handleError((e) => throw e);

  Observable<bool> isFirstOpen() =>
      Observable.fromFuture(prefsProvider.isFirstOpen())
          .handleError((e) => throw e);
}
