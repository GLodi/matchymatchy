import 'package:squazzle/data/models/models.dart';

abstract class LogicProvider {
  /// Determines whether a Move is legal.
  Future<GameField> applyMove(GameField gameField, Move move);

  /// Checks if current player has won.
  Future<bool> checkIfCorrect(GameField gameField, TargetField targetField);
}

class LogicProviderImpl implements LogicProvider {
  @override
  Future<GameField> applyMove(GameField gameField, Move move) async {
    switch (move.dir) {
      case 0:
        {
          // up
          var toMove = gameField.grid[move.from];
          var other = gameField.grid[move.from - 5];
          gameField.grid =
              gameField.grid.replaceRange(move.from, move.from + 1, other);
          gameField.grid =
              gameField.grid.replaceRange(move.from - 5, move.from - 4, toMove);
          return gameField;
        }
      case 1:
        {
          // right
          var toMove = gameField.grid[move.from];
          var other = gameField.grid[move.from + 1];
          gameField.grid =
              gameField.grid.replaceRange(move.from, move.from + 1, other);
          gameField.grid =
              gameField.grid.replaceRange(move.from + 1, move.from + 2, toMove);
          return gameField;
        }
      case 2:
        {
          // down
          var toMove = gameField.grid[move.from];
          var other = gameField.grid[move.from + 5];
          gameField.grid =
              gameField.grid.replaceRange(move.from, move.from + 1, other);
          gameField.grid =
              gameField.grid.replaceRange(move.from + 5, move.from + 6, toMove);
          return gameField;
        }
      case 3:
        {
          // left
          var toMove = gameField.grid[move.from];
          var other = gameField.grid[move.from - 1];
          gameField.grid =
              gameField.grid.replaceRange(move.from, move.from + 1, other);
          gameField.grid =
              gameField.grid.replaceRange(move.from - 1, move.from, toMove);
          return gameField;
        }
      default:
        throw Exception('Wrong direction');
    }
  }

  @override
  Future<bool> checkIfCorrect(
      GameField gameField, TargetField targetField) async {
    bool result = true;
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
    var b = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    for (int i = 0; i < 9; i++) {
      if (gameField.grid[a[i]] != targetField.grid[b[i]]) {
        result = false;
        break;
      }
    }
    return result;
  }
}
