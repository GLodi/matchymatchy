import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase);

let queue = admin.firestore().collection('queue');
let matches = admin.firestore().collection('matches');

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) =>  {
        let userId = request.query.userId;
        let gfid: number = Math.floor(Math.random() * 1000) + 1;
        queue.get().then(async qs => {
            if (qs.empty) {
                let newMatchRef = matches.doc();
                queue.add({
                    time: admin.firestore.Timestamp.now(),
                    uid: userId,
                    gfid: gfid,
                    matchid: newMatchRef.id,
                });
                response.send("queue:"+newMatchRef.id);
            } else {
                // TODO check that user is not going to play with itself
                await queue.orderBy("time", "asc").limit(1).get().then(async q => {
                    await q.docs.forEach(async doc => {
                        queue.doc(doc.id).delete();
                        matches.doc(doc.data().matchid).set({
                            gfid: gfid,
                            hostuid: doc.data().uid,
                            hosttarget: "666666666",
                            joinuid: userId,
                            jointarget: "666666666",
                            time: admin.firestore.Timestamp.now(),
                        });
                        response.send("start:"+doc.data().matchid);
                    });
                });
            }
        });
    });
