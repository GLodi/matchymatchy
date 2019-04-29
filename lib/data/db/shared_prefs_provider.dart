import 'package:shared_preferences/shared_preferences.dart';

import 'package:squazzle/data/models/models.dart';

abstract class SharedPrefsProvider {
  // Store logged user information
  Future<void> storeUser(String username, String uid, String imageUrl);

  // Updates user info from User object
  Future<void> updateUser(User user);

  // Return logged user information
  Future<User> getUser();

  // Return uid of logged user
  Future<String> getUid();

  // Returns true if first time that user opens app
  Future<bool> isFirstOpen();
}

class SharedPrefsProviderImpl extends SharedPrefsProvider {
  SharedPreferences prefs;

  @override
  Future<void> storeUser(String username, String uid, String imageUrl) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('uid', uid);
    prefs.setString('imageUrl', imageUrl);
  }

  @override
  Future<User> getUser() async {
    prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    String uid = prefs.getString('uid');
    String imageUrl = prefs.getString('imageUrl');
    if (username != null && uid != null && imageUrl != null)
      return User(username: username, uid: uid, imageUrl: imageUrl);
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
  Future<void> updateUser(User user) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('username', user.username);
    prefs.setString('uid', user.uid);
    prefs.setString('imageUrl', user.imageUrl);
  }
}
