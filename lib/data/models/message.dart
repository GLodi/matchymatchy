class Message {
  String notiTitle;
  String notiBody;
  String matchId;
  String enemyTarget;

  Message.fromMap(Map<String,dynamic> map) {
    this.notiTitle = map['notification'].cast<String,dynamic>()['title'];
    this.notiBody = map['notification'].cast<String,dynamic>()['body'];
    this.matchId = map['data'].cast<String,dynamic>()['matchid'];
    this.enemyTarget = map['data'].cast<String,dynamic>()['enemytarget'];
  }
}