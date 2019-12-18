import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp(functions.config().firebase)

import { playMove, forfeit } from './play_move'
import { queuePlayer } from './queue_player'
import { getActiveMatches } from './get_active_matches'
import { reconnect } from './reconnect'
import { activeMatchNotification, pastMatchNotification } from './notifications'

exports.queuePlayer = functions
    .region('europe-west1')
    .https.onRequest(async (request, response) =>
        queuePlayer(request, response)
    )

exports.playMove = functions
    .region('europe-west1')
    .https.onRequest(async (request, response) => playMove(request, response))

exports.forfeit = functions
    .region('europe-west1')
    .https.onRequest(async (request, response) => forfeit(request, response))

exports.getActiveMatches = functions
    .region('europe-west1')
    .https.onRequest(async (request, response) =>
        getActiveMatches(request, response)
    )

exports.reconnect = functions
    .region('europe-west1')
    .https.onRequest(async (request, response) => reconnect(request, response))

exports.activeMatchNotification = functions
    .region('europe-west1')
    .firestore.document('matches/{matchId}')
    .onUpdate(async (change, context) =>
        activeMatchNotification(change, context)
    )

exports.pastMatchNotification = functions
    .region('europe-west1')
    .firestore.document('users/{userId}/pastmatches/{matchId}')
    .onCreate(async (_, context) => pastMatchNotification(context))
