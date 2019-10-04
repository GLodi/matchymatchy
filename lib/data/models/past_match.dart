class PastMatch {
  String matchId;
  int moves;
  int enemyMoves;
  String winner;
  int forfeitWin;
  DateTime time;

  PastMatch.fromMap(Map<String, dynamic> map) {
    matchId = map['matchid'];
    moves = int.parse(map['moves'].toString());
    enemyMoves = int.parse(map['enemymoves'].toString());
    winner = map['winner'];
    forfeitWin = map['forfeitwin'] == 'true' ? 1 : 0;
    time = DateTime.fromMillisecondsSinceEpoch(map['time']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'matchid': matchId,
      'moves': moves,
      'enemymoves': enemyMoves,
      'winner': winner,
      'forfeitwin': forfeitWin,
      'time': time.millisecondsSinceEpoch,
    };
  }
}
