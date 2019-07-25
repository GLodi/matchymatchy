import * as admin from 'firebase-admin'
import { QueryDocumentSnapshot } from '@google-cloud/firestore'

let users = admin.firestore().collection('users')
let queue = admin.firestore().collection('queue')
let gamefields = admin.firestore().collection('gamefields')
let matches = admin.firestore().collection('matches')

class StillInMatch extends Error {
    constructor(message: string) {
        super(message);
        this.name = "StillInMatch";
    }
}

export async function queuePlayer(request: any, response: any) {
    console.log('--- start queuePlayer')
    let userId: string = request.query.userId
    let userFcmToken: string = request.query.userFcmToken
    let qs = await queue.get()
    try {
        if (!await alreadyInMatch(userId)) {
            let gf = qs.empty ? await queueEmpty(userId, userFcmToken) :
                await queueNotEmpty(userId, userFcmToken)
            response.send(gf.data())
            console.log('--- end queuePlayer')
        } else throw new StillInMatch(userId + ' is already playing another match')
    } catch (e) {
        // TODO: requeue player?
        console.log('--- error queueing player')
        console.log(e)
        response.send(false)
    }
}

async function alreadyInMatch(userId: string) {
    let user = await users.doc(userId).get()
    return user.data()!.currentMatch != null
}

async function queueEmpty(userId: string, userFcmToken: string) {
    let gfid: number = Math.floor(Math.random() * 1000) + 1
    populateQueue(gfid, userId, userFcmToken)
    let gf = await gamefields.doc(String(gfid)).get()
    return gf
}

function populateQueue(gfid: number, userId: string, userFcmToken: string) {
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
        hostdone: null,
        joindone: null,
    })
    queue.add({
        uid: userId,
        gfid: gfid,
        matchid: newMatchRef.id,
        ufcmtoken: userFcmToken,
        time: admin.firestore.Timestamp.now(),
    })
    users.doc(userId).update({
        currentMatch: newMatchRef.id,
    })
}

async function queueNotEmpty(userId: string, userFcmToken: string) {
    let query = await queue.orderBy('time', 'asc').limit(1).get()
    let matchId = await delQueueStartMatch(query.docs[0], userId, userFcmToken)
    let match = await matches.doc(matchId).get()
    users.doc(userId).update({
        currentMatch: match.id,
    })
    let gf = await gamefields.doc(String(match.data()!.gfid)).get()
    return gf
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string) {
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
