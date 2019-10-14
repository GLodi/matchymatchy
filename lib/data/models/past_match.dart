class PastMatch {
  String matchId;
  String winner;
  String enemyUrl;
  int moves;
  int enemyMoves;
  int forfeitWin;
  DateTime time;

  PastMatch.fromMap(Map<String, dynamic> map) {
    matchId = map['matchid'];
    winner = map['winner'];
    enemyUrl = map['enemyurl'];
    moves = int.parse(map['moves'].toString());
    enemyMoves = int.parse(map['enemymoves'].toString());
    forfeitWin = map['forfeitwin'] == 'true' ? 1 : 0;
    time = DateTime.fromMillisecondsSinceEpoch(map['time']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'matchid': matchId,
      'winner': winner,
      'enemyurl': enemyUrl,
      'moves': moves,
      'enemymoves': enemyMoves,
      'forfeitwin': forfeitWin,
      'time': time.millisecondsSinceEpoch,
    };
  }
}
