import 'package:shared_preferences/shared_preferences.dart';

import 'package:squazzle/data/models/models.dart';

abstract class SharedPrefsProvider {
  Future<void> storeUser(User user);

  Future<User> getUser();

  Future<String> getUid();

  Future<bool> isFirstOpen();
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
}
