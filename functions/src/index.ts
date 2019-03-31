import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase);

let queue = admin.firestore().collection('queue');
let matches = admin.firestore().collection('matches');

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
        let gfid = Math.floor(Math.random() * 1000) + 1;
        
        queue.get().then(qs => {
            if (qs.empty) {
                queue.add({
                    time : admin.firestore.Timestamp.now(),
                    uid : userId,
                    gfid : gfid,
                });
            } else {
                initGame(userId, gfid);
            }
        });

        const users = admin.firestore().collection('a');
        users.doc('SVNNFoT5JcEJrtqL4D6B').set({
            a: 'boh',
        });
    });

function initGame(userId : String, gfid : number) {
    queue.orderBy("time","desc").limit(1).get().then(q => {
        q.docs.forEach(doc => {
            console.log(doc.data().uid);
        });
    });
    /*
    matches.add({
        hostuid : hostuid,
        joinuid : userId,
        gfid : gfid
    });
    */
}