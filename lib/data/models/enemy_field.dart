class EnemyField {
  int uid;
  String grid;

  EnemyField({this.uid, this.grid});

  EnemyField.fromMap(Map<String,dynamic> map) {
    assert(map['uid'] != null);
    assert(map['enemy'] != null);
    assert(map['enemy'].toString().length == 9);
    uid = map['uid'];
    grid = map['enemy'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'enemy' : grid,
    };
  }
}