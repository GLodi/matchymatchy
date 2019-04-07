import 'package:squazzle/data/models/models.dart';

abstract class LogicProvider {
  /// Determines whether a Move is legal.
  Future<GameField> applyMove(GameField gameField, Move move);

  /// Checks if current player has won.
  Future<bool> checkIfCorrect(GameField gameField, TargetField targetField);

  // Checks whether user needs to update enemy player
  Future<bool> needToSendMove(TargetField target);

  // Creates the new TargetField to send to server
  Future<TargetField> diffToSend(GameField gameField, TargetField targetField);
}

class LogicProviderImpl implements LogicProvider {
  TargetField current;
  TargetField previous;

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
          _storeDiff(gameField);
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
          _storeDiff(gameField);
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
          _storeDiff(gameField);
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
          _storeDiff(gameField);
          return gameField;
        }
      default:
        throw Exception('Wrong direction');
    }
  }

  void _storeDiff(GameField gameField) {
    var enemy = "";
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
    for (int i = 0; i < 9; i++) enemy += gameField.grid[a[i]];
    previous = current;
    current = TargetField(grid: enemy);
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

  @override
  Future<bool> needToSendMove(TargetField target) async {
    for (int i = 0; i < current.grid.length; i++) {
      var c = current.grid[i];
      if (c != previous.grid[i] && c == target.grid[i]) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<TargetField> diffToSend(
      GameField gameField, TargetField targetField) async {
    var enemy = "";
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
    var b = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    for (int i = 0; i < 9; i++) {
      if (gameField.grid[a[i]] == targetField.grid[b[i]])
        enemy += gameField.grid[a[i]];
      else
        enemy += '6';
    }
    return TargetField(grid: enemy);
  }
}
