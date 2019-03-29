const functions = require('firebase-functions');
var admin = require('firebase-admin');
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
        
        queue.get().then((qs) => {
            if (qs.empty) {
                queue.add({
                    time : admin.firestore.Timestamp.now(),
                    uid : userId,
                    gfid : gfid,
                });
            } else {
                initGame();
            }
        });


        const users = admin.firestore().collection('a');
        users.doc('SVNNFoT5JcEJrtqL4D6B').set({
            a: 'boh',
        });
    });

function initGame(userId, gfid) {
    let hostuid = queue.orderBy("time","desc").get().uid;
    matches.add({
        hostuid : hostuid,
        joinuid : userId,
        gfid : gfid
    });
}