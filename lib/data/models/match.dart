import 'game_field.dart';
import 'target_field.dart';

class Match {
  GameField gameField;
  TargetField targetField;

  Match({this.gameField, this.targetField});

  Match.fromMap(Map<String, dynamic> map) {
    gameField = GameField(grid: map['grid']);
    targetField = TargetField(grid: map['target']);
  }
}

class MatchOnline extends Match {
  String matchId;
  String enemyName;
  int moves;
  int enemyMoves;
  int gfid;
  int started;
  TargetField enemyTargetField;

  MatchOnline.fromMap(Map<String, dynamic> map) {
    gameField = GameField(grid: map['gf']);
    targetField = TargetField(grid: map['target']);
    matchId = map['matchid'];
    enemyName = map['enemyname'];
    moves = int.parse(map['moves'].toString());
    enemyMoves = int.parse(map['enemymoves'].toString());
    gfid = int.parse(map['gfid'].toString());
    started = int.parse(map['started'].toString());
    enemyTargetField = TargetField(grid: map['enemytarget']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gf': gameField.grid,
      'target': targetField.grid,
      'matchid': matchId,
      'enemyname': enemyName,
      'moves': moves.toString(),
      'enemymoves': enemyMoves.toString(),
      'gfid': gfid.toString(),
      'started': started.toString(),
      'enemytarget': enemyTargetField.grid,
    };
  }
}
