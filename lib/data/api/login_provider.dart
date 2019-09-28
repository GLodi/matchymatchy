import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:squazzle/data/models/models.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

// TODO: add logout option
abstract class LoginProvider {
  Future<User> loginWithGoogle(String fcmToken);
}

class LoginProviderImpl extends LoginProvider {
  @override
  Future<User> loginWithGoogle(String fcmToken) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser fireUser = await _auth.signInWithCredential(credential);
    assert(fireUser.email != null);
    assert(fireUser.displayName != null);
    assert(!fireUser.isAnonymous);
    assert(await fireUser.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(fireUser.uid == currentUser.uid);

    print("signed in " + fireUser.displayName);

    User user = User(
        username: fireUser.displayName,
        uid: fireUser.uid,
        photoUrl: fireUser.photoUrl);

    if (fireUser != null) {
      // Check if already signed up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: fireUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update server if new user
        Firestore.instance.collection('users').document(fireUser.uid).setData({
          'username': fireUser.displayName,
          'photourl': fireUser.photoUrl,
          'uid': fireUser.uid,
          'matcheswon': 0,
          'fcmtoken': fcmToken,
        });
      } else {
        // Retrieve already existing information
        user.matchesWon = documents[0].data['matcheswon'];
      }
    }

    return user;
  }
}
