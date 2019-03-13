import 'game_field.dart';
import 'target_field.dart';

class Game {
  int id;
  GameField gameField;
  TargetField targetField;

  Game({this.id, this.gameField, this.targetField});

}