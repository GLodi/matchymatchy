import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { QueryDocumentSnapshot } from '@google-cloud/firestore'

admin.initializeApp(functions.config().firebase)

let queue = admin.firestore().collection('queue')
let gamefields = admin.firestore().collection('gamefields')
let matches = admin.firestore().collection('matches')
let users = admin.firestore().collection('users')

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start queuePlayer--------------------')
        let userId = request.query.userId
        let userFcmToken = request.query.userFcmToken
        queue.get().then(async qs => {
            if (qs.empty) {
                let gf = await queueEmpty(userId, userFcmToken)
                response.send(gf.data())
                console.log('----------------end queuePlayer new queue--------------------')
            } else {
                let result = await queueNotEmpty(userId, userFcmToken)
                await response.send(result[0].data())
                await notifyPlayersMatchStarted(result[1])
                console.log('----------------end queuePlayer match started--------------------')
            }
        })
    })

async function queueEmpty(userId: string, userFcmToken: string) {
    let gfid: number = Math.floor(Math.random() * 1000) + 1
    await populateQueue(gfid, userId, userFcmToken)
    let gf = await gamefields.doc(String(gfid)).get()
    console.log(gf.data())
    return gf
}

async function queueNotEmpty(userId: string, userFcmToken: string) {
    let query = await queue.orderBy('time', 'asc').limit(1).get()
    if (query.docs[0].exists && query.docs[0].data().uid == userId) {
        // TODO check that user is not going to play with itself

    }
    let matchId = await delQueueStartMatch(query.docs[0], userId, userFcmToken)
    console.log('match started: ' + matchId)
    let match = await matches.doc(matchId).get()
    let gf = await gamefields.doc(String(match.data()!.gfid)).get()
    console.log(gf.data())
    return [gf, matchId]
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
        await admin.messaging().send(messageToHost)
        console.log('message sent to host: ' + match.data()!.hostfcmtoken)
    } catch (error) {
        console.log('error sending message: ' + error)
    }
    try {
        await admin.messaging().send(messageToJoin)
        console.log('message sent to join: ' + match.data()!.joinfcmtoken)
    } catch (error) {
        console.log('error sending message: ' + error)
    }
}

async function populateQueue(gfid: number, userId: string, userFcmToken: string) {
    let newMatchRef = matches.doc()
    newMatchRef.set({
        gfid: gfid,
        hostuid: userId,
        hosttarget: '666666666',
        hostfcmtoken: userFcmToken,
        joinuid: '',
        jointarget: '666666666',
        joinfcmtoken: '',
    })
    queue.add({
        time: admin.firestore.Timestamp.now(),
        uid: userId,
        gfid: gfid,
        matchid: newMatchRef.id,
        ufcmtoken: userFcmToken,
    })
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string) {
    queue.doc(doc.id).delete()
    console.log('queue deleted: ' + doc.id)
    let matchId = doc.data().matchid
    await matches.doc(matchId).update({
        winner: '',
        winnerName: '',
        hostmoves: 1000,
        joinmoves: 1000,
        joinuid: joinUid,
        joinfcmtoken: joinFcmToken,
        time: admin.firestore.Timestamp.now(),
    })
    return matchId
}

exports.playMove = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start playMove--------------------')
        let newTarget = request.query.newTarget
        let userId = request.query.userId
        let matchId = request.query.matchId
        let match = await matches.doc(matchId).get()
        if (match.exists) {
            if (userId == match.data()!.hostuid) {
                await matches.doc(matchId).update({
                    hosttarget: newTarget
                })
                let messageToJoin = {
                    data: {
                        matchid: match.id,
                        enemytarget: newTarget,
                        messType: 'move',
                    },
                    token: match.data()!.joinfcmtoken
                }
                await admin.messaging().send(messageToJoin)
                response.send(true)
                console.log('--- move from host received, sent to join')
                console.log('----------------end playMove--------------------')
            }
            else if (userId == match.data()!.joinuid) {
                await matches.doc(matchId).update({
                    jointarget: newTarget
                })
                let messageToHost = {
                    data: {
                        matchid: match.id,
                        enemytarget: newTarget,
                        messType: 'move',
                    },
                    token: match.data()!.hostfcmtoken
                }
                await admin.messaging().send(messageToHost)
                response.send(true)
                console.log('--- move from join received, sent to host')
                console.log('----------------end playMove--------------------')
            }
            else {
                console.log('error: user neither host nor join')
                response.send(false)
            }
        } else {
            console.log('error: no match with specified matchId')
            response.send(false)
        }
    })

exports.winSignal = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start winSignal--------------------')
        let userId = request.query.userId
        let matchId = request.query.matchId
        let moves = request.query.moves
        let match = await matches.doc(matchId).get()
        if (match.exists) {
            if (match.data()!.winner == '') {
                userId == match.data()!.hostuid ?
                    match.data()!.hostmoves = moves :
                    match.data()!.joinmoves = moves
                let has1Won = await checkWinners(matchId)
                if (has1Won) {
                    await declareWinner(matchId)
                }
                console.log('----------------end winSignal--------------------')
                response.send(true)
            } else {
                console.log('error: match was already won')
                response.send(false)
            }
        } else {
            console.log('error: no match with specified matchId')
            response.send(false)
        }
    })

async function checkWinners(matchId: string) {
    let match = await matches.doc(matchId).get()
    if (match.data()!.winner != '') {
        match.data()!.hostmoves > match.data()!.joinmoves ?
            upWinAmount(matchId, true) : upWinAmount(matchId, false)
        return true
    }
    return false
}

async function upWinAmount(matchId: string, hostOrJoin: boolean) {
    let match = await matches.doc(matchId).get()
    let userRef = await users.doc(
        hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid
    )
    let user = await userRef.get()
    userRef.update({
        matchesWon: user.data()!.matchesWon + 1
    })
    matches.doc(matchId).update({
        winner: hostOrJoin ? match.data()!.hostuid : match.data()!.joinuid,
        winnerName: user.data()!.username,
    })
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
        await admin.messaging().send(messageToJoin)
    } catch (e) {
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
        await admin.messaging().send(messageToHost)
    } catch (e) {
        console.log(e)
    }
}
