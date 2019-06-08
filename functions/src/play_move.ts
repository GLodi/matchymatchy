import * as admin from 'firebase-admin'

let matches = admin.firestore().collection('matches')
let users = admin.firestore().collection('users')

export async function playMove(request: any, response: any) {
    let newTarget = request.query.newTarget
    let userId = request.query.userId
    let moves = request.query.moves
    let won = request.query.won
    let matchId = request.query.matchId
    console.log('--- start playMove: ' + matchId)
    let match = await matches.doc(matchId).get()
    if (match.exists) {
        if (userId == match.data()!.hostuid ||
            userId == match.data()!.joinuid) {
            userId == match.data()!.hostuid ?
                await matches.doc(matchId).update({
                    hosttarget: newTarget
                }) :
                await matches.doc(matchId).update({
                    jointarget: newTarget
                })
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
            if (won) await handleWon(matchId, moves, userId)
            response.send(true)
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

async function handleWon(matchId: string, moves: number, userId: string) {
    let match = await matches.doc(matchId).get()
    userId == match.data()!.hostuid ?
        await matches.doc(matchId).update({
            hostmoves: +moves
        }) :
        await matches.doc(matchId).update({
            joinmoves: +moves
        })
    let has1Won = await checkWinners(matchId)
    if (has1Won) await declareWinner(matchId)
    console.log('DEBUG: handlewon fine')
}

async function checkWinners(matchId: string) {
    let match = await matches.doc(matchId).get()
    console.log('DEBUG: are both moves not null in checkWinner? ' + match.data()!.hostmoves != '' && match.data()!.joinmoves != '')
    if (match.data()!.hostmoves != null && match.data()!.joinmoves != null) {
        match.data()!.hostmoves > match.data()!.joinmoves ?
            upWinAmount(matchId, true) : upWinAmount(matchId, false)
        console.log('DEBUG: checkWinners true')
        return true
    }
    console.log('DEBUG: checkWinners false')
    return false
}

// TODO never called
async function upWinAmount(matchId: string, hostOrJoin: boolean) {
    let match = await matches.doc(matchId).get()
    let userRef = await users.doc(
        hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid
    )
    let user = await userRef.get()
    userRef.update({
        matchesWon: user.data()!.matchesWon + 1
    })
    console.log('DEBUG: QUA ' + hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid)
    matches.doc(matchId).update({
        winner: hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid,
        winnerName: user.data()!.username,
    })
    console.log('DEBUG: upWinAmount fine')
}

async function declareWinner(matchId: string) {
    let match = await matches.doc(matchId).get()
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
    console.log('DEBUG: declareWinner fine')
}
