class GameField {
  List<List<int>> grid;

  GameField({this.grid});

  GameField.copy(GameField gameField) {
    this.grid = gameField.grid;
  }
}