class TargetField {
  String grid;

  TargetField({this.grid});

  TargetField.fromMap(Map<String, dynamic> map) {
    assert(map['target'] != null);
    assert(map['target'].toString().length == 9);
    grid = map['target'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'target': grid,
    };
  }
}
