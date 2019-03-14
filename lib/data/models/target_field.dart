class TargetField {
  int id;
  String grid;

  TargetField({this.id, this.grid});

  TargetField.fromMap(Map<String, dynamic> map) {
    assert(map['_id'] != null);
    assert(map['grid'] != null);
    assert(map['grid'].toString().length == 9);
    id = map['_id'];
    grid = map['grid'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "_id": id,
      "grid": grid,
    };
  }
}