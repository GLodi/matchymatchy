import 'package:shared_preferences/shared_preferences.dart';

import 'package:squazzle/data/models/models.dart';

abstract class SharedPrefsProvider {
  Future<void> storeUser(User user);

  Future<void> storeMatchId(String matchId);

  Future<void> storeGf(GameField gf);

  Future<void> storeTarget(TargetField targetField);

  Future<void> storeMoves(int moves);

  Future<User> getUser();

  Future<String> getMatchId();

  Future<String> getUid();

  Future<bool> isFirstOpen();

  Future<void> restoreMoves();

  Future<void> increaseMoves();

  Future<int> getMoves();

  Future<Session> getCurrentSession();
}

class SharedPrefsProviderImpl extends SharedPrefsProvider {
  SharedPreferences prefs;
  var test;

  SharedPrefsProviderImpl({this.test: false});

  @override
  Future<void> storeUser(User user) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('username', user.username);
    if (!test) prefs.setString('uid', user.uid);
    prefs.setString('photoUrl', user.photoUrl);
    prefs.setInt('matchesWon', user.matchesWon);
  }

  @override
  Future<void> storeMatchId(String matchId) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('matchId', matchId);
  }

  @override
  Future<void> storeGf(GameField gf) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('gf', gf.grid);
  }

  @override
  Future<void> storeTarget(TargetField targetField) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('target', targetField.grid);
  }

  @override
  Future<void> storeMoves(int moves) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setInt('moves', moves);
  }

  @override
  Future<User> getUser() async {
    prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    String uid = prefs.getString('uid');
    String photoUrl = prefs.getString('photoUrl');
    int matchesWon = prefs.getInt('matchesWon');
    if (username != null &&
        uid != null &&
        photoUrl != null &&
        matchesWon != null) {
      return User(
          username: username,
          uid: uid,
          photoUrl: photoUrl,
          matchesWon: matchesWon);
    }
    return null;
  }

  @override
  Future<String> getMatchId() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString('matchId');
  }

  @override
  Future<String> getUid() async {
    prefs = await SharedPreferences.getInstance();
    if (!test)
      return prefs.getString('uid');
    else
      return 'iG00CwdtEscbX1WeqDtl3Qi6E552';
  }

  @override
  Future<bool> isFirstOpen() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first') == null || prefs.getBool('first') == true) {
      prefs.setBool('first', false);
      return true;
    }
    return false;
  }

  @override
  Future<void> restoreMoves() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setInt('moves', 0);
  }

  @override
  Future<void> increaseMoves() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setInt('moves', prefs.getInt('moves') + 1);
  }

  @override
  Future<int> getMoves() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getInt('moves');
  }

  @override
  Future<Session> getCurrentSession() async {
    prefs = await SharedPreferences.getInstance();
    return Session(
        !test ? prefs.getString('uid') : 'iG00CwdtEscbX1WeqDtl3Qi6E552',
        prefs.getString('matchId'),
        prefs.getString('gf'),
        prefs.getString('target'),
        prefs.getInt('moves'));
  }
}
