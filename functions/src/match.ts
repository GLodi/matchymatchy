export class Match {
    gfid: string;
    gf: string;
    target: string;
    enemytarget: string;
    moves: number;

    constructor(gfid: string, gf: string, target: string, enemytarget: string, moves: number) {
        this.gfid = gfid;
        this.gf = gf;
        this.target = target;
        this.enemytarget = enemytarget;
        this.moves = moves;
    }
}
