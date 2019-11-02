import * as admin from 'firebase-admin'
import { ActiveMatch } from './models/active_match'
import { DataNotAvailableError } from './models/exceptions'
import { updateFcmToken } from './updatefcmtoken'
import {
    DocumentReference,
    DocumentSnapshot,
    QueryDocumentSnapshot,
    QuerySnapshot
} from '@google-cloud/firestore'

const users = admin.firestore().collection('users')
const queue = admin.firestore().collection('queue')
const gamefields = admin.firestore().collection('gamefields')
const matches = admin.firestore().collection('matches')

export async function queuePlayer(request: any, response: any) {
    const userId: string = request.query.userId
    const userFcmToken: string = request.query.userFcmToken
    try {
        updateFcmToken(userId, userFcmToken)
        const match: ActiveMatch = await newGame(userId)
        response.send(match)
    } catch (e) {
        if (e instanceof DataNotAvailableError) {
            response.status(210).send()
        } else {
            console.log('--- error queueing player')
            console.error(Error(e))
            response.status(500).send()
        }
    }
}

async function newGame(userId: string): Promise<ActiveMatch> {
    const qs: QuerySnapshot = await queue.get()
    const newMatchId: string = qs.empty
        ? await queueEmpty(userId)
        : await queueNotEmpty(qs, userId)
    const matchDoc: DocumentSnapshot = await matches.doc(newMatchId).get()
    const gf: DocumentSnapshot = await gamefields
        .doc(String(matchDoc.data()!.gfid))
        .get()
    const newMatch: ActiveMatch = new ActiveMatch(
        newMatchId,
        matchDoc.data()!.gfid,
        gf.data()!.grid,
        gf.data()!.target,
        0,
        0,
        'Searching...',
        await diffToSend(gf.data()!.grid, gf.data()!.target),
        '',
        0,
        0
    )
    return newMatch
}

async function queueEmpty(userId: string): Promise<string> {
    const gfid: number = Math.floor(Math.random() * 1000) + 1
    const gf: DocumentSnapshot = await gamefields.doc(String(gfid)).get()
    const userDoc: DocumentSnapshot = await users.doc(userId).get()
    const newMatchRef: DocumentReference = await matches.doc()
    await newMatchRef.set({
        gfid: +gf.id,
        hostmoves: +0,
        hostuid: userId,
        hostgf: gf.data()!.grid,
        hosttarget: await diffToSend(gf.data()!.grid, gf.data()!.target),
        hosturl: userDoc.data()!.photourl,
        joinmoves: +0,
        joinuid: null,
        joingf: gf.data()!.grid,
        jointarget: await diffToSend(gf.data()!.grid, gf.data()!.target),
        winner: null,
        winnername: null,
        hostdone: null,
        joindone: null,
        forfeitwin: 0,
        time: admin.firestore.Timestamp.now().toMillis()
    })
    await queue.add({
        uid: userId,
        gfid: +gf.id,
        matchid: newMatchRef.id,
        time: admin.firestore.Timestamp.now().toMillis()
    })
    return newMatchRef.id
}

async function queueNotEmpty(
    qs: QuerySnapshot,
    userId: string
): Promise<string> {
    const matchId: string = await qs.docs[0].data().matchid
    if (qs.docs[0].get('uid') != userId) {
        const matchDoc: DocumentSnapshot = await matches.doc(matchId).get()
        await delQueueElement(qs.docs[0], userId)
        const hostRef: DocumentReference = await users.doc(
            matchDoc.data()!.hostuid
        )
        const joinRef: DocumentReference = await users.doc(userId)
        hostRef
            .collection('activematches')
            .doc(matchDoc.id)
            .set({})
        joinRef
            .collection('activematches')
            .doc(matchDoc.id)
            .set({})
    }
    return matchId
}

async function delQueueElement(
    doc: QueryDocumentSnapshot,
    joinUid: string
): Promise<void> {
    queue.doc(doc.id).delete()
    const userDoc: DocumentSnapshot = await users.doc(joinUid).get()
    const matchId: string = doc.data().matchid
    await matches.doc(matchId).update({
        hostmoves: 0,
        joinmoves: 0,
        joinuid: joinUid,
        time: admin.firestore.Timestamp.now().toMillis(),
        joinurl: userDoc.data()!.photourl
    })
}

function diffToSend(gf: string, target: string): string {
    let enemy = ''
    var a = [6, 7, 8, 11, 12, 13, 16, 17, 18]
    for (let i = 0; i < 9; i++) {
        if (gf[a[i]] == target[i]) enemy += gf[a[i]]
        else enemy += '6'
    }
    return enemy
}
