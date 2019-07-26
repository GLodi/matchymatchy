import * as admin from 'firebase-admin'

let matches = admin.firestore().collection('matches')
let users = admin.firestore().collection('users')

export async function playMove(request: any, response: any) {
    let newTarget: string = request.query.newTarget
    let userId: string = request.query.userId
    let moves: number = +request.query.moves
    let done: boolean = (request.query.done == 'true')
    let matchId: string = request.query.matchId
    let matchDoc = await matches.doc(matchId).get()
    if (matchDoc.exists) {
        if (userId == matchDoc.data()!.hostuid ||
            userId == matchDoc.data()!.joinuid) {
            await updateMatch(userId, matchId, newTarget, moves)
            if (done) await setPlayerDone(userId, matchId)
            response.send(true)
            if (done &&
                ((matchDoc.data()!.hostdone != null && userId == matchDoc.data()!.joinuid) ||
                    (matchDoc.data()!.joindone != null && userId == matchDoc.data()!.hostuid))) {
                await declareWinner(matchId)
            }
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
    let matchDoc = await matches.doc(matchId).get()
    userId == matchDoc.data()!.hostuid ?
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
    let matchDoc = await matches.doc(matchId).get()
    userId == matchDoc.data()!.hostuid ?
        await matches.doc(matchId).update({
            hostdone: true
        }) :
        await matches.doc(matchId).update({
            joindone: true
        })
}

async function declareWinner(matchId: string) {
    let matchDoc = await matches.doc(matchId).get()
    if (matchDoc.data()!.hostmoves < matchDoc.data()!.joinmoves) {
        await upWinAmount(matchId, true)
    }
    else if (matchDoc.data()!.hostmoves > matchDoc.data()!.joinmoves) {
        await upWinAmount(matchId, false)
    }
    else {
        matches.doc(matchId).update({
            winner: 'draw',
        })
    }
    await resetCurrentMatch(matchId)
}

async function upWinAmount(matchId: string, hostOrJoin: boolean) {
    let matchDoc = await matches.doc(matchId).get()
    let userRef = await users.doc(
        hostOrJoin ? matchDoc.data()!.hostuid : matchDoc.data()!.joinuid
    )
    let user = await userRef.get()
    userRef.update({
        matchesWon: +user.data()!.matchesWon + 1
    })
    matches.doc(matchId).update({
        winner: hostOrJoin ? matchDoc.data()!.hostuid : matchDoc.data()!.joinuid,
        winnerName: user.data()!.username,
    })
}

async function resetCurrentMatch(matchId: string) {
    let matchDoc = await matches.doc(matchId).get()
    let hostRef = await users.doc(matchDoc.data()!.hostuid)
    let joinRef = await users.doc(matchDoc.data()!.joinuid)
    hostRef.update({
        currentMatch: null
    })
    joinRef.update({
        currentMatch: null
    })
}
