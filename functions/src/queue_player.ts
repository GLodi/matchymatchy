import * as admin from 'firebase-admin'
import { Match } from './match'
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
            let newMatch = new Match(gfDoc.id, gfDoc.data()!.grid, gfDoc.data()!.target, gfDoc.data()!.target, 0)
            response.send(newMatch)
        }
        // Already in game, send him his match's situation and let him continue
        else {
            let matchDoc = await matches.doc(currentMatch).get()
            let gfDoc = await gamefields.doc(String(matchDoc.data()!.gfid)).get()
            let hostOrJoin = userId == matchDoc.data()!.hostuid
            let match = new Match(gfDoc.id, gfDoc.data()!.grid,
                hostOrJoin ? matchDoc.data()!.hosttarget : matchDoc.data()!.jointarget,
                hostOrJoin ? matchDoc.data()!.jointarget : matchDoc.data()!.hosttarget,
                hostOrJoin ? matchDoc.data()!.hostmoves : matchDoc.data()!.joinmoves)
            response.send(match)
        }
    } catch (e) {
        // TODO: requeue player?
        console.log('--- error queueing player')
        console.log(e)
        response.send(false)
    }
}

async function alreadyInMatch(userId: string): Promise<string> {
    let user = await users.doc(userId).get()
    return user.data()!.currentMatch != null ? user.data()!.currentMatch : null
}

async function queueEmpty(userId: string, userFcmToken: string): Promise<DocumentSnapshot> {
    let gfid: number = Math.floor(Math.random() * 1000) + 1
    let gf = await gamefields.doc(String(gfid)).get()
    populateQueue(gf, userId, userFcmToken)
    return gf
}

function populateQueue(gf: DocumentSnapshot, userId: string, userFcmToken: string) {
    let newMatchRef = matches.doc()
    newMatchRef.set({
        gfid: +gf.id,
        hostmoves: +0,
        hostuid: userId,
        hosttarget: gf.data()!.target,
        hostfcmtoken: userFcmToken,
        joinmoves: +0,
        joinuid: null,
        jointarget: gf.data()!.target,
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
