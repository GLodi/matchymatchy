export class Session {
    gfid: string;
    gf: string;
    target: string;
    enemytarget: string;
    moves: number;
    enemyname: string;
    started: boolean;

    constructor(gfid: string, gf: string, target: string, enemytarget: string, moves: number, enemyname: string, started: boolean) {
        this.gfid = gfid;
        this.gf = gf;
        this.target = target;
        this.enemytarget = enemytarget;
        this.moves = moves;
        this.enemyname = enemyname;
        this.started = started;
    }
}
