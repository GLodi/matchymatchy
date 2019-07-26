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

  GameOnline.fromMap(Map<String, dynamic> map) {
    assert(map['grid'] != null);
    assert(map['target'] != null);
    assert(map['enemytarget'] != null);
    assert(map['moves'] != null);
    assert(map['grid'].toString().length == 25);
    assert(map['target'].toString().length == 9);
    assert(map['enemytarget'].toString().length == 9);
    gameField = GameField(grid: map['grid']);
    targetField = TargetField(grid: map['target']);
    enemyTargetField = TargetField(grid: map['enemytarget']);
    moves = int.parse(map['moves']);
  }
}
