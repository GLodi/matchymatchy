import 'package:shared_preferences/shared_preferences.dart';

import 'package:matchymatchy/data/models/models.dart';

abstract class SharedPrefsProvider {
  Future<void> storeUser(User user);

  Future<User> getUser();

  Future<String> getUid();

  Future<bool> isFirstOpen();

  Future<void> logout();
}

class SharedPrefsProviderImpl extends SharedPrefsProvider {
  SharedPreferences prefs;

  @override
  Future<void> storeUser(User user) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('username', user.username);
    prefs.setString('uid', user.uid);
    prefs.setString('photoUrl', user.photoUrl);
    prefs.setInt('matchesWon', user.matchesWon);
  }

  @override
  Future<User> getUser() async {
    print("quiquiqui");
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
    return prefs.getString('uid');
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
  Future<void> logout() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('uid');
    prefs.remove('photoUrl');
    prefs.remove('matchesWon');
  }
}
