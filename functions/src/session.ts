export class Session {
  matchid: string;
  gfid: string;
  gf: string;
  target: string;
  moves: number;
  enemymoves: number;
  enemyname: string;
  enemytarget: string;
  started: boolean;

  constructor(
    matchid: string,
    gfid: string,
    gf: string,
    target: string,
    moves: number,
    enemymoves: number,
    enemyname: string,
    enemytarget: string,
    started: boolean
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
