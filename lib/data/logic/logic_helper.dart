import 'package:squazzle/data/models/models.dart';

class LogicHelper {
  GameField game;
  TargetField target;

  Future<GameField> getGame() async {
    var grid = [
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
    ];
    game = GameField(grid: grid);
    return game;
  }

  Future<TargetField> getTarget() async {
    var grid = [
      [1,2,3],
      [1,2,3],
      [1,2,3],
    ];
    target = TargetField(grid: grid);
    return target;
  }

  Future<GameField> applyMove(Move move) async {
    switch(move.dir) {
      case 0: {
        var toMove = game.grid[(move.from/5).truncate()][move.from%5];
        var other = game.grid[(move.from/5).truncate()-1][(move.from%5)];
        game.grid[(move.from/5).truncate()][move.from%5] = other;
        game.grid[(move.from/5).truncate()-1][(move.from%5)] = toMove;
        return game;
      }
      case 1: {
        var toMove = game.grid[(move.from/5).truncate()][move.from%5];
        var other = game.grid[(move.from/5).truncate()][(move.from%5)+1];
        game.grid[(move.from/5).truncate()][move.from%5] = other;
        game.grid[(move.from/5).truncate()][(move.from%5)+1] = toMove;
        return game;
      }
      case 2: {
        var toMove = game.grid[(move.from/5).truncate()][move.from%5];
        var other = game.grid[(move.from/5).truncate()+1][(move.from%5)];
        game.grid[(move.from/5).truncate()][move.from%5] = other;
        game.grid[(move.from/5).truncate()+1][(move.from%5)] = toMove;
        return game;
      }
      case 3: {
        var toMove = game.grid[(move.from/5).truncate()][move.from%5];
        var other = game.grid[(move.from/5).truncate()][(move.from%5)-1];
        game.grid[(move.from/5).truncate()][move.from%5] = other;
        game.grid[(move.from/5).truncate()][(move.from%5)-1] = toMove;
        return game;
      }
      default: throw Exception('Wrong direction');
    }
  }

  Future<bool> checkIfCorrect() async {
    bool result = true;
    for(int i = 1; i < 4; i++) {
      for(int j = 1; j < 4; j++) {
        if (game.grid[i][j] != target.grid[i-1][j-1]) {
          result = false;
          break;
        }
      }
      if (result == false) break;
    }
    return result;
  }

}