import 'net_utils.dart';

import 'package:squazzle/data/models/models.dart';

class ApiHelper {
  final NetUtils _net;

  ApiHelper(this._net);

  Future<GameField> getGame() async {
    var grid = [
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
      [1,2,3,4,5],
    ];
    return GameField(grid: grid);
  }
}