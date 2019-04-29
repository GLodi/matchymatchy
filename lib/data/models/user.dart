class User {
  String username;
  String uid;
  String imageUrl;
  int matchesWon;

  User({this.username, this.uid, this.imageUrl, this.matchesWon = 0});

  User.fromMap(Map<String, dynamic> map) {
    assert(map['username'] != null);
    assert(map['uid'] != null);
    assert(map['imageUrl'] != null);
    assert(map['matchesWon'] != null);
    username = map['username'];
    uid = map['uid'];
    imageUrl = map['imageUrl'];
    matchesWon = map['matchesWon'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'uid': uid,
      'imageUrl': imageUrl,
      'matchesWon': matchesWon,
    };
  }
}
