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
                let id : string = await empty(gfid, userId);
                response.send(id);
            } else {
                // TODO check that user is not going to play with itself
                let query = await queue.orderBy("time", "asc").limit(1).get();
                await query.docs.forEach(async doc => {
                    queue.doc(doc.id).delete();
                    let match = await matches.doc(doc.data().matchid).get();
                    if (match.exists) {
                        matches.doc(match.id).set({
                            gfid: match.data()!.gfid,
                            hostuid: match.data()!.hostuid,
                            hosttarget: match.data()!.hosttarget,
                            joinuid: "666666666",
                            jointarget: "666666666",
                            time: admin.firestore.Timestamp.now(),
                        });
                    }
                    response.send(doc.data().matchid);
                });
            }
        });
    });
    
async function empty(gfid : number, userId : string) : Promise<string> {
    let newMatchRef = matches.doc();
    newMatchRef.set({
        gfid: gfid,
        hostuid: userId,
        hosttarget: "666666666",
        joinuid: "",
        jointarget: "666666666",
    });
    queue.add({
        time: admin.firestore.Timestamp.now(),
        uid: userId,
        gfid: gfid,
        matchid: newMatchRef.id,
    });
    return new Promise<string>((resolve) => {resolve(newMatchRef.id);});
}
