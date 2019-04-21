import 'package:squazzle/data/models/models.dart';

abstract class LogicProvider {
  /// Determines whether a Move is legal.
  Future<GameField> applyMove(GameField gameField, Move move);

  /// Checks if current player has won.
  Future<bool> checkIfCorrect(GameField gameField, TargetField targetField);

  // Checks whether user needs to update enemy player
  bool needToSendMove(GameField gameField, TargetField targetField);

  // Creates the new TargetField to send to server
  TargetField diffToSend(GameField gameField, TargetField targetField);
}

class LogicProviderImpl implements LogicProvider {
  GameField current;

  @override
  Future<GameField> applyMove(GameField gameField, Move move) async {
    switch (move.dir) {
      case 0:
        {
          // up
          current = GameField(grid: gameField.grid);
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
          current = GameField(grid: gameField.grid);
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
          current = GameField(grid: gameField.grid);
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
          current = GameField(grid: gameField.grid);
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
    for (int i = 0; i < 9; i++) {
      if (gameField.grid[a[i]] != targetField.grid[i]) {
        result = false;
        break;
      }
    }
    return result;
  }

  @override
  bool needToSendMove(GameField gameField, TargetField targetField) {
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
    for (int i = 0; i < 9; i++) {
      if (current.grid[a[i]] != gameField.grid[a[i]] &&
          gameField.grid[a[i]] == targetField.grid[i]) {
        return true;
      }
    }
    return false;
  }

  @override
  TargetField diffToSend(GameField gameField, TargetField targetField) {
    var enemy = "";
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
    for (int i = 0; i < 9; i++) {
      if (gameField.grid[a[i]] == targetField.grid[i])
        enemy += gameField.grid[a[i]];
      else
        enemy += '6';
    }
    return TargetField(grid: enemy);
  }
}
