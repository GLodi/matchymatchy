export class ActiveMatch {
  matchid: string;
  gfid: string;
  gf: string;
  target: string;
  moves: number;
  enemymoves: number;
  enemyname: string;
  enemytarget: string;
  started: number;

  constructor(
    matchid: string,
    gfid: string,
    gf: string,
    target: string,
    moves: number,
    enemymoves: number,
    enemyname: string,
    enemytarget: string,
    started: number
  ) {
    this.matchid = matchid;
    this.gfid = gfid;
    this.gf = gf;
    this.target = target;
    this.moves = moves;
    this.enemymoves = enemymoves;
    this.enemyname = enemyname;
    this.enemytarget = enemytarget;
    this.started = started;
  }
}
