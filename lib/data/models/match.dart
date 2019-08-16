import 'game_field.dart';
import 'target_field.dart';

class Match {
  GameField gameField;
  TargetField targetField;

  Match({this.gameField, this.targetField});

  Match.fromMap(Map<String, dynamic> map) {
    assert(map['grid'] != null);
    assert(map['target'] != null);
    assert(map['grid'].toString().length == 25);
    assert(map['target'].toString().length == 9);
    gameField = GameField(grid: map['grid']);
    targetField = TargetField(grid: map['target']);
  }
}

class MatchOnline extends Match {
  String matchId;
  String enemyName;
  int moves;
  int gfid;
  bool started;
  TargetField enemyTargetField;

  MatchOnline.fromMap(Map<String, dynamic> map) {
    assert(map['gfid'] != null);
    assert(map['matchid'] != null);
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
    assert(map['gfid'] >= 0);
    gameField = GameField(grid: map['gf']);
    targetField = TargetField(grid: map['target']);
    enemyTargetField = TargetField(grid: map['enemytarget']);
    gfid = map['gfid'];
    moves = map['moves'];
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
      'started': started,
      'enemyname': enemyName,
    };
  }
}
