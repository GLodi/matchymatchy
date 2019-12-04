import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:matchymatchy/data/models/models.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

abstract class LoginProvider {
  Future<User> loginWithGoogle(String fcmToken);
}

class LoginProviderImpl extends LoginProvider {
  @override
  Future<User> loginWithGoogle(String fcmToken) async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser fireUser = authResult.user;
    assert(fireUser.email != null);
    assert(fireUser.displayName != null);
    assert(!fireUser.isAnonymous);
    assert(await fireUser.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(fireUser.uid == currentUser.uid);

    print("signed in " + fireUser.displayName);

    User user = User(
        username: fireUser.displayName.toLowerCase(),
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
          'username': fireUser.displayName.toLowerCase(),
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
