class MoveMessage {
  String matchId;
  String enemyTarget;

  MoveMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
    this.enemyTarget = map['data'].cast<String, dynamic>()['enemytarget'];
  }
}

class WinnerMessage {
  String winner;
  String matchId;
  String enemyName;

  WinnerMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
    this.winner = map['data'].cast<String, dynamic>()['winner'];
    this.enemyName = map['data'].cast<String, dynamic>()['enemyName'];
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
