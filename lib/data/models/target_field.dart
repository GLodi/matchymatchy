class TargetField {
  int id;
  String grid;

  TargetField({this.id, this.grid});

  TargetField.fromMap(Map<String, dynamic> map) {
    assert(map['_id'] != null);
    assert(map['target'] != null);
    assert(map['target'].toString().length == 9);
    id = map['_id'];
    grid = map['target'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'target': grid,
    };
  }
}
