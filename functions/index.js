const functions = require('firebase-functions');
var admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.helloWorld = functions
    .region('europe-west1')
    .https
    .onRequest((request, response) => {
        response.send("Hello from Firebase!");
    });

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => {
        let userId = request.query.senderId;
        let senderName = request.query.senderName;
        let handleType = request.query.handleType;

        const users = admin.firestore().collection('a');
        users.doc('SVNNFoT5JcEJrtqL4D6B').set({
            a: 'boh',
        });
    });