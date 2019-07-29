export class Match {
    gfid: string;
    gf: string;
    target: string;
    enemytarget: string;
    moves: number;
    started: boolean;

    constructor(gfid: string, gf: string, target: string, enemytarget: string, moves: number, started: boolean) {
        this.gfid = gfid;
        this.gf = gf;
        this.target = target;
        this.enemytarget = enemytarget;
        this.moves = moves;
        this.started = started;
    }
}
