import * as admin from 'firebase-admin'
import { DataNotAvailableError } from './models/exceptions'
import { DocumentReference, DocumentSnapshot } from '@google-cloud/firestore'

const matches = admin.firestore().collection('matches')
const users = admin.firestore().collection('users')

export async function playMove(request: any, response: any) {
    const userId: string = request.query.userId
    const matchId: string = request.query.matchId
    const newGf: string = request.query.newGf
    const newTarget: string = request.query.newTarget
    const done: boolean = request.query.done == 'true'
    const moves: number = +request.query.moves
    try {
        const matchDoc: DocumentSnapshot = await matches.doc(matchId).get()
        // TODO: don't throw, check if match was won
        if (!matchDoc.exists) throw new DataNotAvailableError()
        await updateMatch(userId, matchDoc, newGf, newTarget, moves)
        if (done) await setPlayerDone(userId, matchDoc)
        response.send(true)
        if (done && isOtherPlayerDone(userId, matchDoc)) {
            declareWinner(matchDoc.id)
        }
    } catch (e) {
        if (e instanceof DataNotAvailableError) {
            response.status(204).send()
        } else {
            console.log('--- error applying player move')
            console.error(Error(e))
            response.status(500).send()
        }
    }
}

function isOtherPlayerDone(
    firstPlayer: string,
    matchDoc: DocumentSnapshot
): boolean {
    return (
        (matchDoc.data()!.hostdone != null &&
            firstPlayer == matchDoc.data()!.joinuid) ||
        (matchDoc.data()!.joindone != null &&
            firstPlayer == matchDoc.data()!.hostuid)
    )
}

async function updateMatch(
    userId: string,
    matchDoc: DocumentSnapshot,
    newGf: string,
    newTarget: string,
    moves: number
) {
    userId == matchDoc.data()!.hostuid
        ? await matches.doc(matchDoc.id).update({
              hostgf: newGf,
              hosttarget: newTarget,
              hostmoves: +moves
          })
        : await matches.doc(matchDoc.id).update({
              joingf: newGf,
              jointarget: newTarget,
              joinmoves: +moves
          })
}

async function setPlayerDone(userId: string, matchDoc: DocumentSnapshot) {
    userId == matchDoc.data()!.hostuid
        ? await matches.doc(matchDoc.id).update({
              hostdone: true
          })
        : await matches.doc(matchDoc.id).update({
              joindone: true
          })
}

async function declareWinner(matchId: string) {
    const matchDoc: DocumentSnapshot = await matches.doc(matchId).get()
    if (matchDoc.data()!.hostmoves < matchDoc.data()!.joinmoves) {
        await upWinAmount(matchDoc, true)
    } else if (matchDoc.data()!.hostmoves > matchDoc.data()!.joinmoves) {
        await upWinAmount(matchDoc, false)
    }
    await storePastMatch(await matches.doc(matchDoc.id).get())
}

async function upWinAmount(matchDoc: DocumentSnapshot, hostOrJoin: boolean) {
    const userRef: DocumentReference = users.doc(
        hostOrJoin ? matchDoc.data()!.hostuid : matchDoc.data()!.joinuid
    )
    const user: DocumentSnapshot = await userRef.get()
    userRef.update({
        matcheswon: +user.data()!.matcheswon + 1
    })
    await matches.doc(matchDoc.id).update({
        winner: hostOrJoin
            ? matchDoc.data()!.hostuid
            : matchDoc.data()!.joinuid,
        winnername: user.data()!.username
    })
}

async function storePastMatch(matchDoc: DocumentSnapshot) {
    const hostRef: DocumentReference = users.doc(matchDoc.data()!.hostuid)
    const joinRef: DocumentReference = users.doc(matchDoc.data()!.joinuid)
    const hostDoc: DocumentSnapshot = await hostRef.get()
    const joinDoc: DocumentSnapshot = await joinRef.get()
    hostRef
        .collection('pastmatches')
        .doc(matchDoc.id)
        .set({
            enemyurl: matchDoc.data()!.joinurl,
            matchid: matchDoc.id,
            moves: matchDoc.data()!.hostmoves,
            enemymoves: matchDoc.data()!.joinmoves,
            enemyname: joinDoc.data()!.username,
            winner: matchDoc.data()!.winnername,
            time: admin.firestore.Timestamp.now().toMillis(),
            isplayerhost: 1,
            isplayerwinner:
                matchDoc.data()!.winner == hostDoc.data()!.uid ? 1 : 0
        })
    joinRef
        .collection('pastmatches')
        .doc(matchDoc.id)
        .set({
            enemyurl: matchDoc.data()!.hosturl,
            matchid: matchDoc.id,
            moves: matchDoc.data()!.joinmoves,
            enemymoves: matchDoc.data()!.hostmoves,
            enemyname: hostDoc.data()!.username,
            winner: matchDoc.data()!.winnername,
            time: admin.firestore.Timestamp.now().toMillis(),
            isplayerhost: 0,
            isplayerwinner:
                matchDoc.data()!.winner == joinDoc.data()!.uid ? 1 : 0
        })
    await resetMatch(matchDoc)
}

async function resetMatch(matchDoc: DocumentSnapshot) {
    const hostRef: DocumentReference = users.doc(matchDoc.data()!.hostuid)
    const joinRef: DocumentReference = users.doc(matchDoc.data()!.joinuid)
    hostRef
        .collection('activematches')
        .doc(matchDoc.id)
        .delete()
    joinRef
        .collection('activematches')
        .doc(matchDoc.id)
        .delete()
    matches.doc(matchDoc.id).delete()
}

export async function forfeit(request: any, response: any) {
    const userId: string = request.query.userId
    const matchId: string = request.query.matchId
    try {
        const matchDoc: DocumentSnapshot = await matches.doc(matchId).get()
        if (!matchDoc.exists) throw new DataNotAvailableError()
        if (matchDoc.data()!.winner == null) {
            if (userId == matchDoc.data()!.hostuid) {
                await upWinAmount(matchDoc, false)
            }
            if (userId == matchDoc.data()!.joinuid) {
                await upWinAmount(matchDoc, true)
            }
            response.send(true)
        } else {
            response.send(false)
        }
    } catch (e) {
        if (e instanceof DataNotAvailableError) {
            response.status(204).send()
        } else {
            console.log('--- error forfeting player player')
            console.error(Error(e))
            response.status(500).send()
        }
    }
}
