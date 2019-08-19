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
  bool started;
  TargetField enemyTargetField;

  MatchOnline.fromMap(Map<String, dynamic> map) {
    gameField = GameField(grid: map['gf']);
    targetField = TargetField(grid: map['target']);
    enemyTargetField = TargetField(grid: map['enemytarget']);
    gfid = int.parse(map['gfid'].toString());
    moves = int.parse(map['moves'].toString());
    enemyMoves = int.parse(map['enemymoves'].toString());
    started = map['started'];
    enemyName = map['enemyname'];
    matchId = map['matchid'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'matchid': matchId,
      'gfid': gfid.toString(),
      'gf': gameField.grid,
      'target': targetField.grid,
      'enemytarget': enemyTargetField.grid,
      'moves': moves.toString(),
      'enemymoves': enemyMoves.toString(),
      'started': started,
      'enemyname': enemyName,
    };
  }
}
