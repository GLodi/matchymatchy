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
    gameField = GameField.fromMap(map);
    targetField = TargetField.fromMap(map);
  }
}
