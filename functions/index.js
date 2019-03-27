const functions = require('firebase-functions');
var admin = require('firebase-admin');
var app = admin.initializeApp();

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
        admin.firestore().FieldValue.serverTimestamp();
        let docSnapshot = admin.firestore().collection('a').doc('SVNNFoT5JcEJrtqL4D6B').get();
        docSnapshot.set({a: 'sdfsd'});
        response.send("Hello from Firebase!");
    });