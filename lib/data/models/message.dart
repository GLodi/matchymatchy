class EnemyMoveMessage {
  String matchId;
  String enemyTarget;
  int enemyMoves;

  EnemyMoveMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
    this.enemyTarget = map['data'].cast<String, dynamic>()['enemytarget'];
    this.enemyMoves =
        int.parse(map['data'].cast<String, dynamic>()['enemymoves']);
  }
}

class WinnerMessage {
  String winner;
  String matchId;

  WinnerMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
    this.winner = map['data'].cast<String, dynamic>()['winner'];
  }
}

class ChallengeMessage {
  String matchId;
  String enemyName;

  ChallengeMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
    this.enemyName = map['data'].cast<String, dynamic>()['enemyName'];
  }
}

class ForfeitMessage {
  String matchId;

  ForfeitMessage(this.matchId);
}

class PlayerMessage {
  String matchId;

  PlayerMessage(this.matchId);
}
