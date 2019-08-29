class PastMatch {
  int moves;
  int enemyMoves;
  String winner;
  int forfeitWin;

  PastMatch.fromMap(Map<String, dynamic> map) {
    moves:
    int.parse(map['moves'].toString());
    enemyMoves:
    int.parse(map['enemymoves'].toString());
    winner:
    map['winner'];
    forfeitWin:
    map['forfeitwin'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'moves': moves,
      'enemymoves': enemyMoves,
      'winner': winner,
      'forfeitwin': forfeitWin,
    };
  }
}
