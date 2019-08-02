export class Session {
    matchid: string
    gfid: string
    gf: string
    target: string
    enemytarget: string
    moves: number
    enemyname: string
    started: boolean

    constructor(matchid: string, gfid: string, gf: string, target: string, enemytarget: string, moves: number, enemyname: string, started: boolean) {
        this.matchid = matchid
        this.gfid = gfid
        this.gf = gf
        this.target = target
        this.enemytarget = enemytarget
        this.moves = moves
        this.enemyname = enemyname
        this.started = started
    }
}
