import * as admin from 'firebase-admin'
import { QueryDocumentSnapshot } from '@google-cloud/firestore'

let queue = admin.firestore().collection('queue')
let gamefields = admin.firestore().collection('gamefields')
let matches = admin.firestore().collection('matches')
let users = admin.firestore().collection('users')

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
    if (qs.empty) {
        let gf = await queueEmpty(userId, userFcmToken)
        response.send(gf.data())
        console.log('--- end queuePlayer new queue')
    } else {
        try {
            let result = await queueNotEmpty(userId, userFcmToken)
            await response.send(result[0].data())
            await notifyPlayersMatchStarted(result[1])
        } catch (e) {
            console.log('error queueing player, prolly queueing against himself')
        }
        console.log('---- end queuePlayer match started')
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
    })
    queue.add({
        time: admin.firestore.Timestamp.now(),
        uid: userId,
        gfid: gfid,
        matchid: newMatchRef.id,
        ufcmtoken: userFcmToken,
    })
}

async function queueNotEmpty(userId: string, userFcmToken: string) {
    let query = await queue.orderBy('time', 'asc').limit(1).get()
    if (query.docs[0].exists && query.docs[0].data().uid == userId) {
        // TODO: check that user is not going to play against itself
        throw new AlreadyQueueingError(userId + " is already queued")

    }
    let matchId = await delQueueStartMatch(query.docs[0], userId, userFcmToken)
    console.log('match started: ' + matchId)
    let match = await matches.doc(matchId).get()
    let gf = await gamefields.doc(String(match.data()!.gfid)).get()
    console.log(gf.data())
    return [gf, matchId]
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string) {
    queue.doc(doc.id).delete()
    console.log('queue deleted: ' + doc.id)
    let matchId = doc.data().matchid
    await matches.doc(matchId).update({
        winner: '',
        winnerName: '',
        hostmoves: 0,
        joinmoves: 0,
        joinuid: joinUid,
        joinfcmtoken: joinFcmToken,
        time: admin.firestore.Timestamp.now(),
    })
    return matchId
}

async function notifyPlayersMatchStarted(matchId: string) {
    let match = await matches.doc(matchId).get()
    let hostDoc = await users.where('uid', '==', match.data()!.hostuid).get()
    let hostName = await hostDoc.docs[0].data().username
    let joinDoc = await users.where('uid', '==', match.data()!.joinuid).get()
    let joinName = await joinDoc.docs[0].data().username
    let messageToHost = {
        data: {
            matchid: match.id,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            messType: 'challenge',
            enemyName: joinName,
        },
        notification: {
            title: 'Match started!',
            body: joinName + ' challenged you!',
        },
        token: match.data()!.hostfcmtoken
    }
    let messageToJoin = {
        data: {
            matchid: match.id,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            messType: 'challenge',
            enemyName: hostName,
        },
        notification: {
            title: 'Match started!',
            body: hostName + ' challenged you!',
        },
        token: match.data()!.joinfcmtoken,
    }
    try {
        admin.messaging().send(messageToHost)
        console.log('message sent to host: ' + match.data()!.hostfcmtoken)
    } catch (error) {
        console.log('error sending message: ' + error)
    }
    try {
        admin.messaging().send(messageToJoin)
        console.log('message sent to join: ' + match.data()!.joinfcmtoken)
    } catch (error) {
        console.log('error sending message: ' + error)
    }
}
