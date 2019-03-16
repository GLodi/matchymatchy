class GameField {
  int id;
  String grid;
  String target;

  GameField({this.id, this.grid, this.target});

  GameField.fromMap(Map<String, dynamic> map){
    assert(map['_id'] != null);
    assert(map['grid'] != null);
    assert(map['target'] != null);
    assert(map['grid'].toString().length == 25);
    assert(map['target'].toString().length == 9);
    id = map['_id'];
    grid = map['grid'];
    target = map['target'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "_id" : id,
      "grid" : grid,
      "target" : target,
    };
  }

}