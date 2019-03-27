import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

abstract class LoginRepo {
  // Try login through Google services
  Future<FirebaseUser> loginWithGoogle();
}

class LoginRepoImpl extends LoginRepo {
  @override
  Future<FirebaseUser> loginWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print("signed in " + user.displayName);

    if (user != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance.collection('users').document(user.uid).setData({
          'username': user.displayName,
          'photoUrl': user.photoUrl,
          'uid': user.uid,
          'matchesWon': 0,
        });
      }
    }

    return user;
  }
}
