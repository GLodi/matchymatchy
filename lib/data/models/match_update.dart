class MatchUpdate {
  int gfid;
  String hosttarget;
  String jointarget;

  MatchUpdate({this.gfid, this.hosttarget, this.jointarget});

  MatchUpdate.fromMap(Map<String, dynamic> map) {
    assert(map['gfid'] != null);
    assert(map['hosttarget'] != null);
    assert(map['jointarget'] != null);
    gfid = map['gfid'];
    hosttarget = map['hosttarget'];
    jointarget = map['jointarget'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gfid': gfid,
      'hosttarget': hosttarget,
      'jointarget': jointarget,
    };
  }
}