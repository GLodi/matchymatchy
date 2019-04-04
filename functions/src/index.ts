import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { QueryDocumentSnapshot, QuerySnapshot } from '@google-cloud/firestore';
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore';

admin.initializeApp(functions.config().firebase);

let queue = admin.firestore().collection('queue');
let matches = admin.firestore().collection('matches');
let users = admin.firestore().collection('users');

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start queuePlayer--------------------')
        let userId = request.query.userId;
        let userFcmToken = request.query.userFcmToken;
        let gfid: number = Math.floor(Math.random() * 1000) + 1;
        queue.get().then(async qs => {
            if (qs.empty) {
                await populateQueue(gfid, userId, userFcmToken);
                response.send(true);
                console.log('----------------end queuePlayer new queue--------------------')
            } else {
                // TODO check that user is not going to play with itself
                let query: QuerySnapshot = await queue.orderBy('time', 'asc').limit(1).get();
                let match: DocumentSnapshot = await delQueueStartMatch(query.docs[0], userId, userFcmToken);
                await notifyPlayersMatchStarted(match.id);
                console.log('match started: ' + match.id);
                response.send(true);
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
            matchId: match.id,
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
            matchId: match.id,
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

async function populateQueue(gfid: number, userId: string, userFcmToken: string): Promise<string> {
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
    return new Promise<string>((resolve) => { resolve(newMatchRef.id); });
}

async function delQueueStartMatch(doc: QueryDocumentSnapshot, joinUid: string, joinFcmToken: string): Promise<DocumentSnapshot> {
    queue.doc(doc.id).delete();
    console.log('queue deleted: ' + doc.id);
    await matches.doc(doc.data().matchid).update({
        joinuid: joinUid,
        joinfcmtoken: joinFcmToken,
        time: admin.firestore.Timestamp.now(),
    });
    return await matches.doc(doc.data().matchid).get();
}

exports.playMove = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        console.log('----------------start playMove--------------------')
        let newTarget = request.query.newToken;
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
                        matchId: match.id,
                        newTarget: newTarget,
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
                        matchId: match.id,
                        newTarget: newTarget,
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
