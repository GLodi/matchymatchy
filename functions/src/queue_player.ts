import * as admin from 'firebase-admin'
import { Session } from './session'
import { DocumentSnapshot, QueryDocumentSnapshot } from '@google-cloud/firestore'

let users = admin.firestore().collection('users')
let queue = admin.firestore().collection('queue')
let gamefields = admin.firestore().collection('gamefields')
let matches = admin.firestore().collection('matches')

// Queue handling
// Waits for a player's connection: checks if he's currently
// playing in a match (if which case it sends him the current
// match's situation) or he's ready for a new game.
export async function queuePlayer(request: any, response: any) {
    let userId: string = request.query.userId
    let userFcmToken: string = request.query.userFcmToken
    let qs = await queue.get()
    try {
        let currentMatch = await alreadyInMatch(userId)
        // Not already in match, put him in queue
        if (currentMatch == null) {
            // Queue can either be empty or full.
            // If empty, create new element in queue and wait for someone.
            // if full, join other player's match and start game.
            let gfDoc = qs.empty ? await queueEmpty(userId, userFcmToken) :
                await queueNotEmpty(userId, userFcmToken)
            let diff = await diffToSend(gfDoc.data()!.grid, gfDoc.data()!.target)
            let newMatch = new Session(gfDoc.id, gfDoc.data()!.grid, gfDoc.data()!.target, diff, 0, '', false)
            response.send(newMatch)
        }
        // Already in game, send him his match's situation and let him continue
        else {
            let matchDoc = await matches.doc(currentMatch).get()
            let hostOrJoin = userId == matchDoc.data()!.hostuid
            hostOrJoin ?
                await matches.doc(currentMatch).update({
                    hostfcmtoken: userFcmToken
                }) :
                await matches.doc(currentMatch).update({
                    joinfcmtoken: userFcmToken
                })
            let gfDoc = await gamefields.doc(String(matchDoc.data()!.gfid)).get()
            let match = new Session(gfDoc.id,
                hostOrJoin ? matchDoc.data()!.hostgf : matchDoc.data()!.joingf,
                gfDoc.data()!.target,
                hostOrJoin ? matchDoc.data()!.jointarget : matchDoc.data()!.hosttarget,
                hostOrJoin ? matchDoc.data()!.hostmoves : matchDoc.data()!.joinmoves,
                hostOrJoin ? await getUsername(matchDoc.data()!.joinuid) : await getUsername(matchDoc.data()!.hostuid), true)
            response.send(match)
        }
    } catch (e) {
        // TODO: requeue player?
        console.log('--- error queueing player')
        console.log(e)
        response.send(false)
    }
}

async function getUsername(userId: string): Promise<string> {
    let user = await users.doc(userId).get()
    return user.data()!.username
}

async function alreadyInMatch(userId: string): Promise<string> {
    let user = await users.doc(userId).get()
    return user.data()!.currentMatch != null ? user.data()!.currentMatch : null
}

async function queueEmpty(userId: string, userFcmToken: string): Promise<DocumentSnapshot> {
    let gfid: number = Math.floor(Math.random() * 1000) + 1
    let gf = await gamefields.doc(String(gfid)).get()
    await populateQueue(gf, userId, userFcmToken)
    return gf
}

async function populateQueue(gf: DocumentSnapshot, userId: string, userFcmToken: string) {
    let newMatchRef = matches.doc()
    newMatchRef.set({
        gfid: +gf.id,
        hostmoves: +0,
        hostuid: userId,
        hostgf: gf.data()!.grid,
        hosttarget: await diffToSend(gf.data()!.grid, gf.data()!.target),
        hostfcmtoken: userFcmToken,
        joinmoves: +0,
        joinuid: null,
        joingf: gf.data()!.grid,
        jointarget: await diffToSend(gf.data()!.grid, gf.data()!.target),
        joinfcmtoken: null,
        winner: '',
        winnerName: '',
        hostdone: null,
        joindone: null,
    })
    queue.add({
        uid: userId,
        gfid: +gf.id,
        matchid: newMatchRef.id,
        ufcmtoken: userFcmToken,
        time: admin.firestore.Timestamp.now(),
    })
    users.doc(userId).update({
        currentMatch: newMatchRef.id,
    })
}

async function queueNotEmpty(userId: string, userFcmToken: string): Promise<DocumentSnapshot> {
    let query = await queue.orderBy('time', 'asc').limit(1).get()
    let matchId = await delQueueStartMatch(query.docs[0], userId, userFcmToken)
    let match = await matches.doc(matchId).get()
    users.doc(userId).update({
        currentMatch: match.id,
    })
    let gf = await gamefields.doc(String(match.data()!.gfid)).get()
    return gf
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string): Promise<string> {
    queue.doc(doc.id).delete()
    let matchId = doc.data().matchid
    await matches.doc(matchId).update({
        hostmoves: 0,
        joinmoves: 0,
        joinuid: joinUid,
        joinfcmtoken: joinFcmToken,
        time: admin.firestore.Timestamp.now(),
    })
    return matchId
}

async function diffToSend(gf: string, target: string): Promise<string> {
    let enemy = ""
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18]
    for (let i = 0; i < 9; i++) {
        if (gf[a[i]] == target[i])
            enemy += gf[a[i]]
        else
            enemy += '6'
    }
    return enemy
}
