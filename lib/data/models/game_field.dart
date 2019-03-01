class GameField {
  List<List<int>> grid;

  GameField({this.grid});

  GameField.fromMap(Map<String, dynamic> map)
      : assert(map['grid'] != null),
        grid = map['grid'];

  GameField.copy(GameField gameField) {
    this.grid = gameField.grid;
  }
}