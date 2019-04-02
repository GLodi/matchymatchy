import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase);

let queue = admin.firestore().collection('queue');
let matches = admin.firestore().collection('matches');
let gamefields = admin.firestore().collection('gamefields');

exports.helloWorld = functions
    .region('europe-west1')
    .https
    .onRequest((request, response) => {
        response.send("Hello from Firebase!");
    });

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest((request, response) => {
        let userId = request.query.userId;
        let gfid: number = Math.floor(Math.random() * 1000) + 1;
        queue.get().then(qs => {
            if (qs.empty) {
                queue.add({
                    time: admin.firestore.Timestamp.now(),
                    uid: userId,
                    gfid: gfid,
                });
            } else {
                // TODO check that user is not going to play with itself
                initGame(userId, String(gfid));
            }
        });

        const users = admin.firestore().collection('a');
        users.doc('SVNNFoT5JcEJrtqL4D6B').set({
            a: 'boh',
        });
    });

async function initGame(userId: string, gfid: string) {
    let initialGf: string =
        await gamefields.doc(gfid).get()
            .then(gf => gf.data()!.grid)
            .catch(e => console.log(e));
    let initialTarget = await getCurrentTarget(initialGf);
    queue.orderBy("time", "asc").limit(1).get().then(q => {
        q.docs.forEach(doc => {
            matches.add({
                hostuid: doc.data().uid,
                joinuid: userId,
                gfid: gfid,
                hosttarget: initialTarget,
                jointarget: initialTarget,
            });
        });
    });
}

async function getCurrentTarget(gf: string) {
    let initialTarget: string = "";
    let array = [6, 7, 8, 11, 12, 13, 16, 17, 18];
    for (var c of array) {
        initialTarget = initialTarget.concat(gf.charAt(c));
    }
    return initialTarget;
}