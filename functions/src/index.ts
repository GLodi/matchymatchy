import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { QueryDocumentSnapshot } from '@google-cloud/firestore';

admin.initializeApp(functions.config().firebase);

let queue = admin.firestore().collection('queue');
let gamefields = admin.firestore().collection('gamefields');
let matches = admin.firestore().collection('matches');
let users = admin.firestore().collection('users');

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start queuePlayer--------------------')
        let userId = request.query.userId;
        let userFcmToken = request.query.userFcmToken;
        queue.get().then(async qs => {
            if (qs.empty) {
                let gfid: number = Math.floor(Math.random() * 1000) + 1;
                await populateQueue(gfid, userId, userFcmToken);
                let gf = await gamefields.doc(String(gfid)).get();
                console.log(gf.data());
                response.send(gf.data());
                console.log('----------------end queuePlayer new queue--------------------')
            } else {
                // TODO check that user is not going to play with itself
                let query = await queue.orderBy('time', 'asc').limit(1).get();
                let matchId = await delQueueStartMatch(query.docs[0], userId, userFcmToken);
                console.log('match started: ' + matchId);
                let match = await matches.doc(matchId).get();
                let gf = await gamefields.doc(String(match.data()!.gfid)).get();
                console.log(gf.data());
                await response.send(gf.data());
                await notifyPlayersMatchStarted(matchId);
                console.log('----------------end queuePlayer match started--------------------')
            }
        });
    });

async function notifyPlayersMatchStarted(matchId: string) {
    let match = await matches.doc(matchId).get();
    let hostDoc = await users.where('uid', '==', match.data()!.hostuid).get();
    let hostName = await hostDoc.docs[0].data().username;
    let joinDoc = await users.where('uid', '==', match.data()!.joinuid).get();
    let joinName = await joinDoc.docs[0].data().username;
    let messageToHost = {
        data: {
            matchid: match.id,
            enemytarget: '666666666',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            notificationType: 'challenge',
        },
        notification: {
            title: 'Match started!',
            body: joinName + ' challenged you!',
        },
        token: match.data()!.hostfcmtoken
    };
    let messageToJoin = {
        data: {
            matchid: match.id,
            enemytarget: '666666666',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            notificationType: 'challenge',
        },
        notification: {
            title: 'Match started!',
            body: hostName + ' challenged you!',
        },
        token: match.data()!.joinfcmtoken,
    };
    try {
        await admin.messaging().send(messageToHost);
        console.log('message sent to: ' + match.data()!.hostfcmtoken);
    } catch (error) {
        console.log('error sending message: ' + error);
    }
    try {
        await admin.messaging().send(messageToJoin);
        console.log('message sent to: ' + match.data()!.joinfcmtoken);
    } catch (error) {
        console.log('error sending message: ' + error);
    }
}

async function populateQueue(gfid: number, userId: string, userFcmToken: string) {
    let newMatchRef = matches.doc();
    newMatchRef.set({
        gfid: gfid,
        hostuid: userId,
        hosttarget: '666666666',
        hostfcmtoken: userFcmToken,
        joinuid: '',
        jointarget: '666666666',
        joinfcmtoken: '',
    });
    queue.add({
        time: admin.firestore.Timestamp.now(),
        uid: userId,
        gfid: gfid,
        matchid: newMatchRef.id,
        ufcmtoken: userFcmToken,
    });
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string): Promise<string> {
    queue.doc(doc.id).delete();
    console.log('queue deleted: ' + doc.id);
    let matchId = doc.data().matchid;
    await matches.doc(matchId).update({
        joinuid: joinUid,
        joinfcmtoken: joinFcmToken,
        time: admin.firestore.Timestamp.now(),
    });
    return matchId;
}

exports.playMove = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start playMove--------------------')
        let newTarget = request.query.newTarget;
        let userId = request.query.userId;
        let matchId = request.query.matchId;
        let match = await matches.doc(matchId).get();
        if (match.exists) {
            if (userId == match.data()!.hostuid) {
                await matches.doc(matchId).update({
                    hosttarget: newTarget
                });
                let messageToJoin = {
                    data: {
                        matchid: match.id,
                        enemytarget: newTarget,
                    },
                    token: match.data()!.joinfcmtoken
                };
                await admin.messaging().send(messageToJoin);
                response.send(true);
                console.log('----------------end queuePlayer--------------------')
            }
            else if (userId == match.data()!.joinuid) {
                await matches.doc(matchId).update({
                    jointarget: newTarget
                });
                let messageToHost = {
                    data: {
                        matchid: match.id,
                        enemytarget: newTarget,
                    },
                    token: match.data()!.hostfcmtoken
                };
                await admin.messaging().send(messageToHost);
                response.send(true);
                console.log('----------------end queuePlayer--------------------')
            }
            else {
                console.log('error: user neither host nor join')
                response.send(false);
            }
        }
        console.log('error: no match with specified matchId')
        response.send(false);
    })
