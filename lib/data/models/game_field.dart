class GameField {
  int id;
  String grid;

  GameField({this.id, this.grid});

  GameField.fromMap(Map<String, dynamic> map) {
    assert(map['_id'] != null);
    assert(map['grid'] != null);
    assert(map['grid'].toString().length == 25);
    id = map['_id'];
    grid = map['grid'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'grid': grid,
    };
  }
}
