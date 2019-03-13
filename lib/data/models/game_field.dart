class GameField {
  List<int> grid;

  GameField({this.grid});

  GameField.fromMap(Map<String, dynamic> map){
    assert(map['grid'] != null);
    this.grid = new List<int>.from(map['grid']);
  }

  GameField.copy(GameField gameField) {
    this.grid = gameField.grid;
  }
}