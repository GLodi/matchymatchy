import 'net_utils.dart';

import 'package:squazzle/data/models/models.dart';

class ApiHelper {
  final NetUtils _net;
  GameField game;

  ApiHelper(this._net);

  Future<GameField> getGame() async {
    var grid = [
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
    ];
    game = GameField(grid: grid);
    return GameField(grid: grid);
  }

  Future<GameField> applyMove(Move move) async {
    switch(move.dir) {
      case 0: {
        break;
      }
      case 1: {
        var toMove = game.grid[(move.from/5).truncate()][move.from%5];
        var other = game.grid[(move.from/5).truncate()][(move.from%5)+1];
        game.grid[(move.from/5).truncate()][move.from%5] = other;
        game.grid[(move.from/5).truncate()][(move.from%5)+1] = toMove;
        return game;
      }
      case 2: {
        break;
      }
      case 3: {
        break;
      }
      default: throw Exception('Wrong direction');
    }
  }
}