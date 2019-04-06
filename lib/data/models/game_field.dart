class GameField {
  String grid;

  GameField({this.grid});

  GameField.fromMap(Map<String, dynamic> map) {
    assert(map['grid'] != null);
    assert(map['grid'].toString().length == 25);
    grid = map['grid'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'grid': grid,
    };
  }
}
