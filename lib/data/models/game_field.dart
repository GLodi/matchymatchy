class GameField {
  List<List<int>> grid;

  GameField({this.grid});

  GameField.fromMap(Map<String, dynamic> map){
    assert(map['grid'] != null);
    var list = List<List<int>>();
    for (int j=0; j<5; j++) {
      var temp = List<int>();
      for (int i=0; i<map['grid'][j].length; i++)
        temp.add(int.parse(map['grid'][j][i]));
      list.add(temp);
    }
    this.grid = list;
  }

  GameField.copy(GameField gameField) {
    this.grid = gameField.grid;
  }
}