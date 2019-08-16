class TargetField {
  String grid;

  TargetField({this.grid});

  TargetField.fromMap(Map<String, dynamic> map) {
    grid = map['target'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'target': grid,
    };
  }
}
