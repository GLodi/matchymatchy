import 'package:squazzle/data/models/models.dart';

abstract class LogicProvider {

  Future<GameField> getGame(); // move to db

  Future<TargetField> getTarget(); // move to db

  /// Determines whether a Move is legal.
  Future<GameField> applyMove(Move move); // add gamefield parameter

  /// Checks if current player has won.
  Future<bool> checkIfCorrect(); // add gamefield and targetfield param

  Future<int> getMovesNumber(); // move to db

}

class LogicProviderImpl implements LogicProvider {
  GameField game;
  TargetField target;
  int movesNumber = 0;

  @override
  Future<int> getMovesNumber() async {
    return movesNumber;
  }

  @override
  Future<GameField> getGame() async {
    var grid = [0,1,2,3,4,1,2,3,4,5,2,3,4,5,0,3,4,5,0,1,4,5,0,1,2];
    game = GameField(grid: grid);
    return game;
  }

  @override
  Future<TargetField> getTarget() async {
    var grid = [
      [2,3,4],
      [2,3,4],
      [2,3,4],
    ];
    target = TargetField(grid: grid);
    return target;
  }

  @override
  Future<GameField> applyMove(Move move) async {
    movesNumber += 1;
    switch(move.dir) {
      case 0: { // up
        var toMove = game.grid[move.from];
        var other = game.grid[move.from-5];
        game.grid[move.from] = other;
        game.grid[move.from-5] = toMove;
        return game;
      }
      case 1: { // right
        var toMove = game.grid[move.from];
        var other = game.grid[move.from+1];
        game.grid[move.from] = other;
        game.grid[move.from+1] = toMove;
        return game;
      }
      case 2: { // down
        var toMove = game.grid[move.from];
        var other = game.grid[move.from+5];
        game.grid[move.from] = other;
        game.grid[move.from+5] = toMove;
        return game;
      }
      case 3: { // left
        var toMove = game.grid[move.from];
        var other = game.grid[move.from-1];
        game.grid[move.from] = other;
        game.grid[move.from-1] = toMove;
        return game;
      }
      default: throw Exception('Wrong direction');
    }
  }

  @override
  Future<bool> checkIfCorrect() async {
    bool result = true;
    for(int i = 5; i < 7; i++) {
      for(int j = 1; j < 4; j++) {
        if (game.grid[i+j] != target.grid[(i-1)-(j-1)]) {
          result = false;
          break;
        }
      }
      if (result == false) break;
    }
    return result;
  }

}