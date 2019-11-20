export class ActiveMatch {
    matchid: string
    gfid: string
    gf: string
    target: string
    moves: number
    enemymoves: number
    enemyname: string
    enemytarget: string
    enemyurl: string
    started: number
    playerdone: number
    time: number

    constructor(
        matchid: string,
        gfid: string,
        gf: string,
        target: string,
        moves: number,
        enemymoves: number,
        enemyname: string,
        enemytarget: string,
        enemyurl: string,
        started: number,
        playerdone: number,
        time: number
    ) {
        this.matchid = matchid
        this.gfid = gfid
        this.gf = gf
        this.target = target
        this.moves = moves
        this.enemymoves = enemymoves
        this.enemyname = enemyname
        this.enemytarget = enemytarget
        this.enemyurl = enemyurl
        this.started = started
        this.playerdone = playerdone
        this.time = time
    }
}
