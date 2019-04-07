class MatchUpdate {
  String matchId;
  String enemyTarget;

  MatchUpdate({this.matchId, this.enemyTarget});

  MatchUpdate.fromMap(Map<String, dynamic> map) {
    assert(map['matchid'] != null);
    assert(map['enemytarget'] != null);
    matchId = map['matchid'];
    enemyTarget = map['enemytarget'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'matchid': matchId,
      'enemytarget': enemyTarget,
    };
  }
}