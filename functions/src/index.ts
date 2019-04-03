import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase);

let queue = admin.firestore().collection('queue');
let matches = admin.firestore().collection('matches');

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        let userId = request.query.userId;
        let gfid: number = Math.floor(Math.random() * 1000) + 1;
        queue.get().then(async qs => {
            if (qs.empty) {
                let newMatchRef = matches.doc();
                newMatchRef.set({
                    gfid: gfid,
                    hostuid: userId,
                    hosttarget: "666666666",
                });
                queue.add({
                    time: admin.firestore.Timestamp.now(),
                    uid: userId,
                    gfid: gfid,
                    matchid: newMatchRef.id,
                });
                response.send(newMatchRef.id);
            } else {
                // TODO check that user is not going to play with itself
                let query = await queue.orderBy("time", "asc").limit(1).get();
                await query.docs.forEach(async doc => {
                    queue.doc(doc.id).delete();
                    let match = await matches.doc(doc.data().matchid).get();
                    if (match.exists) {
                        matches.doc(match.id).set({
                            gfid: match.data()!.gfid,
                            hostuid: match.data()!.userId,
                            hosttarget: match.data()!.hosttarget,
                            joinuid: userId,
                            jointarget: "666666666",
                            time: admin.firestore.Timestamp.now(),
                        });
                    }
                    response.send(doc.data().matchid);
                });
            }
        });
    });
