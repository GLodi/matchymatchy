class User {
  String username;
  String uid;
  String imageUrl;

  User({this.username, this.uid, this.imageUrl});

  User.fromMap(Map<String,dynamic> map){
    assert(map['username'] != null);
    assert(map['uid'] != null);
    assert(map['imageUrl'] != null);
    username = map['username'];
    uid = map['uid'];
    imageUrl = map['imageUrl'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username' : username,
      'uid' : uid,
      'imageUrl' : imageUrl,
    };
  }

}