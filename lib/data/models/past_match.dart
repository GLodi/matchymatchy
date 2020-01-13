class PastMatch {
  String matchId;
  String winner;
  String enemyUrl;
  String enemyName;
  int moves;
  int enemyMoves;
  int isPlayerHost;
  int isPlayerWinner;
  DateTime time;

  PastMatch.fromMap(Map<String, dynamic> map) {
    matchId = map['matchid'];
    winner = map['winner'];
    enemyUrl = map['enemyurl'];
    enemyName = map['enemyname'];
    moves = int.parse(map['moves'].toString());
    enemyMoves = int.parse(map['enemymoves'].toString());
    isPlayerHost = int.parse(map['isplayerhost'].toString());
    isPlayerWinner = int.parse(map['isplayerwinner'].toString());
    time = DateTime.fromMillisecondsSinceEpoch(map['time']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'matchid': matchId,
      'winner': winner,
      'enemyname': enemyName,
      'enemyurl': enemyUrl,
      'moves': moves,
      'enemymoves': enemyMoves,
      'isplayerhost': isPlayerHost,
      'isplayerwinner': isPlayerWinner,
      'time': time.millisecondsSinceEpoch,
    };
  }
}
