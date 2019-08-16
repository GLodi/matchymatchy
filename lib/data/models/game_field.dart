class GameField {
  String grid;

  GameField({this.grid});

  GameField.fromMap(Map<String, dynamic> map) {
    grid = map['grid'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'grid': grid,
    };
  }
}
