import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp(functions.config().firebase)

import { playMove } from './playmove';
import { queuePlayer } from './queueplayer';

exports.playMove = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => playMove(request, response))

exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => queuePlayer(request, response))
