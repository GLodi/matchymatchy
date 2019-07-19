import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp(functions.config().firebase)

import { playMove } from './play_move';
import { queuePlayer } from './queue_player';

// Handle queueing player
exports.queuePlayer = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => queuePlayer(request, response))

// Handle player's move
exports.playMove = functions
    .region('europe-west1')
    .https
    .onRequest(async (request, response) => playMove(request, response))

// Update other player on enemy's move and update both on player win
exports.notifyUser = functions
    .region('europe-west1')
    .firestore
    .document('matches/{matchId}')
    .onUpdate((change, context) => {
        const newMatch = change.after.data()
        const oldMatch = change.before.data()
        if (newMatch != null && oldMatch != null) {
            if (newMatch.hosttarget != oldMatch.hosttarget) {
                let message = {
                    data: {
                        matchid: context.params.matchId,
                        enemytarget: newMatch.hosttarget,
                        messType: 'move',
                    },
                    token: newMatch.joinfcmtoken,
                }
                try {
                    admin.messaging().send(message)
                } catch (e) {
                    console.log('--- error sending message')
                    console.log(e)
                }
            }
            if (newMatch.jointarget != oldMatch.jointarget) {
                let message = {
                    data: {
                        matchid: context.params.matchId,
                        enemytarget: newMatch.jointarget,
                        messType: 'move',
                    },
                    token: newMatch.hostfcmtoken,
                }
                try {
                    admin.messaging().send(message)
                } catch (e) {
                    console.log('--- error sending message')
                    console.log(e)
                }
            }
            if (newMatch.winner != oldMatch.winner) {
                let messageToJoin = {
                    data: {
                        matchid: context.params.matchId,
                        winner: newMatch.winner,
                        messType: 'winner',
                        winnerName: newMatch.winnerName,
                    },
                    token: newMatch.joinfcmtoken
                }
                let messageToHost = {
                    data: {
                        matchid: context.params.matchId,
                        winner: newMatch.winner,
                        messType: 'winner',
                        winnerName: newMatch.winnerName,
                    },
                    token: newMatch.hostfcmtoken
                }
                try {
                    admin.messaging().send(messageToJoin)
                } catch (e) {
                    console.log('--- error sending message')
                    console.log(e)
                }
                try {
                    admin.messaging().send(messageToHost)
                } catch (e) {
                    console.log('--- error sending message')
                    console.log(e)
                }
            }
        }
        return true
    })
