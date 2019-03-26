import 'game_field.dart';
import 'target_field.dart';

class Game {
  int id;
  GameField gameField;
  TargetField targetField;

  Game({this.id, this.gameField, this.targetField});

  Game.fromMap(Map<String, dynamic> map) {
    assert(map['_id'] != null);
    assert(map['grid'] != null);
    assert(map['target'] != null);
    assert(map['grid'].toString().length == 25);
    assert(map['target'].toString().length == 9);
    id = map['_id'];
    gameField = GameField.fromMap(map);
    targetField = TargetField.fromMap(map);
  }
}
