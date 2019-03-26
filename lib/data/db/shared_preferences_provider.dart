import 'package:shared_preferences/shared_preferences.dart';

import 'package:squazzle/data/models/models.dart';

abstract class SharedPreferencesProvider {
  // Store logged user information
  Future<void> storeUser(String username, String uid, String imageUrl);

  // Return logged user information
  Future<User> getUser();
}

class SharedPreferencesProviderImpl extends SharedPreferencesProvider {
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
}
