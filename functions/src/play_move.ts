import * as admin from 'firebase-admin'

let matches = admin.firestore().collection('matches')
let users = admin.firestore().collection('users')

export async function playMove(request: any, response: any) {
    let newTarget: string = request.query.newTarget
    let userId: string = request.query.userId
    let moves: number = +request.query.moves
    let done: boolean = (request.query.done == 'true')
    let matchId: string = request.query.matchId
    console.log('--- start playMove: ' + matchId)
    let match = await matches.doc(matchId).get()
    if (match.exists) {
        if (userId == match.data()!.hostuid ||
            userId == match.data()!.joinuid) {
            await updateMatch(userId, matchId, newTarget, moves)
            if (done) await setPlayerDone(userId, matchId)
            response.send(true)
            if (done &&
                ((match.data()!.hostdone != null && userId == match.data()!.joinuid) ||
                    (match.data()!.joindone != null && userId == match.data()!.hostuid))) {
                console.log('checktrue')
                await declareWinner(matchId)
            }
            console.log('--- move received')
            console.log('--- end playMove: ' + matchId)
        }
        else {
            console.log('--- error: user neither host nor join')
            response.send(false)
        }
    } else {
        console.log('--- error: no match with specified matchId')
        response.send(false)
    }
}

async function updateMatch(userId: string, matchId: string, newTarget: string, moves: number) {
    let match = await matches.doc(matchId).get()
    userId == match.data()!.hostuid ?
        await matches.doc(matchId).update({
            hosttarget: newTarget,
            hostmoves: +moves
        }) :
        await matches.doc(matchId).update({
            jointarget: newTarget,
            joinmoves: +moves
        })
}

async function setPlayerDone(userId: string, matchId: string) {
    let match = await matches.doc(matchId).get()
    userId == match.data()!.hostuid ?
        await matches.doc(matchId).update({
            hostdone: true
        }) :
        await matches.doc(matchId).update({
            joindone: true
        })
}

async function declareWinner(matchId: string) {
    let match = await matches.doc(matchId).get()
    if (match.data()!.hostmoves < match.data()!.joinmoves) {
        await upWinAmount(matchId, true)
    }
    else if (match.data()!.hostmoves > match.data()!.joinmoves) {
        await upWinAmount(matchId, false)
    }
    else {
        matches.doc(matchId).update({
            winner: 'draw',
        })
    }
}

async function upWinAmount(matchId: string, hostOrJoin: boolean) {
    let match = await matches.doc(matchId).get()
    let userRef = await users.doc(
        hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid
    )
    let user = await userRef.get()
    userRef.update({
        matchesWon: +user.data()!.matchesWon + 1
    })
    matches.doc(matchId).update({
        winner: hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid,
        winnerName: user.data()!.username,
    })
}
