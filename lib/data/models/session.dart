/// Session object that store current game's information
class Session {
  String uid;
  String matchId;
  String gf; // Player's gamefield
  String target; // Player's central 9 squares
  int moves;

  Session(this.uid, this.matchId, this.gf, this.target, this.moves);
}
