import * as admin from 'firebase-admin'
import { QueryDocumentSnapshot } from '@google-cloud/firestore'

let queue = admin.firestore().collection('queue')
let gamefields = admin.firestore().collection('gamefields')
let matches = admin.firestore().collection('matches')

class AlreadyQueueingError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "AlreadyQueueingError";
    }
}

export async function queuePlayer(request: any, response: any) {
    console.log('--- start queuePlayer')
    let userId: string = request.query.userId
    let userFcmToken: string = request.query.userFcmToken
    let qs = await queue.get()
    try {
        let gf = qs.empty ? await queueEmpty(userId, userFcmToken) :
            await queueNotEmpty(userId, userFcmToken)
        response.send(gf.data())
        console.log('--- end queuePlayer')
    } catch (e) {
        console.log('--- error queueing player')
        console.log(e)
        response.send(false)
    }
}

async function queueEmpty(userId: string, userFcmToken: string) {
    let gfid: number = Math.floor(Math.random() * 1000) + 1
    await populateQueue(gfid, userId, userFcmToken)
    let gf = await gamefields.doc(String(gfid)).get()
    console.log(gf.data())
    return gf
}

async function populateQueue(gfid: number, userId: string, userFcmToken: string) {
    let newMatchRef = matches.doc()
    newMatchRef.set({
        gfid: gfid,
        hostuid: userId,
        hosttarget: null,
        hostfcmtoken: userFcmToken,
        joinuid: null,
        jointarget: null,
        joinfcmtoken: null,
        winner: '',
        winnerName: '',
    })
    queue.add({
        uid: userId,
        gfid: gfid,
        matchid: newMatchRef.id,
        ufcmtoken: userFcmToken,
        time: admin.firestore.Timestamp.now(),
    })
}

async function queueNotEmpty(userId: string, userFcmToken: string) {
    let query = await queue.orderBy('time', 'asc').limit(1).get()
    if (query.docs[0].exists && query.docs[0].data().uid == userId) {
        console.log("--- error: double queue")
        throw new AlreadyQueueingError(userId + " is already queued")
    }
    let matchId = await delQueueStartMatch(query.docs[0], userId, userFcmToken)
    console.log('match started: ' + matchId)
    let match = await matches.doc(matchId).get()
    let gf = await gamefields.doc(String(match.data()!.gfid)).get()
    console.log(gf.data())
    return gf
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string) {
    queue.doc(doc.id).delete()
    console.log('queue deleted: ' + doc.id)
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
