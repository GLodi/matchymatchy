import 'game_field.dart';
import 'target_field.dart';

class Game {
  GameField gameField;
  TargetField targetField;

  Game({this.gameField, this.targetField});

  Game.fromMap(Map<String, dynamic> map) {
    assert(map['grid'] != null);
    assert(map['target'] != null);
    assert(map['grid'].toString().length == 25);
    assert(map['target'].toString().length == 9);
    gameField = GameField(grid: map['grid']);
    targetField = TargetField(grid: map['target']);
  }
}

class GameOnline extends Game {
  TargetField enemyTargetField;
  int moves;
  bool started;
  String enemyName;

  GameOnline.fromMap(Map<String, dynamic> map) {
    assert(map['gfid'] != null);
    assert(map['gf'] != null);
    assert(map['target'] != null);
    assert(map['enemytarget'] != null);
    assert(map['moves'] != null);
    assert(map['started'] != null);
    assert(map['enemyname'] != null);
    assert(map['gf'].toString().length == 25);
    assert(map['target'].toString().length == 9);
    assert(map['enemytarget'].toString().length == 9);
    assert(map['moves'] >= 0);
    gameField = GameField(grid: map['gf']);
    targetField = TargetField(grid: map['target']);
    enemyTargetField = TargetField(grid: map['enemytarget']);
    moves = map['moves'];
    started = map['started'];
    enemyName = map['enemyname'];
  }
}
