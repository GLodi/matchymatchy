export class Match {
    gfid: string;
    gf: string;
    target: string;
    enemytarget: string;
    constructor(gfid: string, gf: string, target: string, enemytarget: string) {
        this.gfid = gfid;
        this.gf = gf;
        this.target = target;
        this.enemytarget = enemytarget;
    }
}
