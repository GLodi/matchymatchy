import * as admin from 'firebase-admin'

let matches = admin.firestore().collection('matches')
let users = admin.firestore().collection('users')

export async function playMove(request: any, response: any) {
    let newTarget: string = request.query.newTarget
    let userId: string = request.query.userId
    let moves: number = +request.query.moves
    let won: boolean = (request.query.won == 'true')
    let matchId: string = request.query.matchId
    console.log('--- start playMove: ' + matchId)
    let match = await matches.doc(matchId).get()
    if (match.exists) {
        if (userId == match.data()!.hostuid ||
            userId == match.data()!.joinuid) {
            await updateTarget(userId, matchId, newTarget)
            await upMoves(matchId, userId, moves)
            let message = {
                data: {
                    matchid: match.id,
                    enemytarget: newTarget,
                    messType: 'move',
                },
                token: userId == match.data()!.hostuid ?
                    match.data()!.joinfcmtoken :
                    match.data()!.hostfcmtoken
            }
            try {
                admin.messaging().send(message)
            } catch (e) {
                console.log('error sending message')
                console.log(e)
            }
            response.send(true)
            if (won) {
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

async function updateTarget(userId: string, matchId: string, newTarget: string) {
    let match = await matches.doc(matchId).get()
    userId == match.data()!.hostuid ?
        await matches.doc(matchId).update({
            hosttarget: newTarget
        }) :
        await matches.doc(matchId).update({
            jointarget: newTarget
        })
}

async function upMoves(matchId: string, userId: string, moves: number) {
    let match = await matches.doc(matchId).get()
    userId == match.data()!.hostuid ?
        await matches.doc(matchId).update({
            hostmoves: +moves
        }) :
        await matches.doc(matchId).update({
            joinmoves: +moves
        })
}

async function declareWinner(matchId: string) {
    let match = await matches.doc(matchId).get()
    match.data()!.hostmoves > match.data()!.joinmoves ?
        upWinAmount(matchId, true) : upWinAmount(matchId, false)
    let messageToJoin = {
        data: {
            matchid: match.id,
            winner: match.data()!.winner,
            messType: 'winner',
            winnerName: match.data()!.winnerName,
        },
        token: match.data()!.joinfcmtoken
    }
    try {
        admin.messaging().send(messageToJoin)
    } catch (e) {
        console.log('error sending message')
        console.log(e)
    }
    let messageToHost = {
        data: {
            matchid: match.id,
            winner: match.data()!.winner,
            messType: 'winner',
            winnerName: match.data()!.winnerName,
        },
        token: match.data()!.hostfcmtoken
    }
    try {
        admin.messaging().send(messageToHost)
    } catch (e) {
        console.log('error sending message')
        console.log(e)
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
