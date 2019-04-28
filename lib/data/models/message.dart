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

  WinnerMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
    this.winner = map['data'].cast<String, dynamic>()['winner'];
  }
}

class ChallengeMessage {
  String matchId;

  ChallengeMessage.fromMap(Map<String, dynamic> map) {
    this.matchId = map['data'].cast<String, dynamic>()['matchid'];
  }
}
