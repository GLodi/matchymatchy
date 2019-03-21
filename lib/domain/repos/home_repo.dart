import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:squazzle/data/data.dart';

class HomeRepo {
  final LoginProvider _loginProvider;

  HomeRepo(this._loginProvider);

  Observable<FirebaseUser> loginWithGoogle() => 
      Observable.fromFuture(_loginProvider.loginWithGoogle())
        .handleError((e) => throw e);

}