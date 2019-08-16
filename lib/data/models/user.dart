class User {
  String username;
  String uid;
  String photoUrl;
  int matchesWon;
  String currentMatch;

  User({this.username, this.uid, this.photoUrl, this.matchesWon = 0});

  User.fromMap(Map<String, dynamic> map) {
    username = map['username'];
    uid = map['uid'];
    photoUrl = map['photoUrl'];
    matchesWon = map['matchesWon'];
    currentMatch = map['currentMatch'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'uid': uid,
      'photoUrl': photoUrl,
      'matchesWon': matchesWon,
      'currentMatch': currentMatch,
    };
  }
}
