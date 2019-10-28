import * as admin from 'firebase-admin'
import { QuerySnapshot, DocumentSnapshot } from '@google-cloud/firestore'

import { ActiveMatch } from './models/active_match'

const matches = admin.firestore().collection('matches')
const users = admin.firestore().collection('users')

export async function getActiveMatches(request: any, response: any) {
    try {
        const userId: string = request.query.userId
        const activeMatchesQuery = await users
            .doc(userId)
            .collection('activematches')
            .get()
        const activeMatches: ActiveMatch[] = await makeList(
            userId,
            activeMatchesQuery
        )
        response.send(activeMatches)
    } catch (e) {
        console.log('--- error getting player matches')
        console.error(Error(e))
        response.status(500).send()
    }
}

async function makeList(
    userId: string,
    activeMatchesQuery: QuerySnapshot
): Promise<ActiveMatch[]> {
    const list: ActiveMatch[] = []
    for (const doc of activeMatchesQuery.docs) {
        const match: DocumentSnapshot = await matches.doc(doc.id).get()
        !match.exists
            ? deleteReference(userId, doc.id)
            : list.push(await pushOnList(userId, match))
    }
    return list
}

async function pushOnList(
    userId: string,
    match: DocumentSnapshot
): Promise<ActiveMatch> {
    if (userId == match.data()!.hostuid) {
        const enemy: DocumentSnapshot = await users
            .doc(match.data()!.joinuid)
            .get()
        return new ActiveMatch(
            match.id,
            match.data()!.gfid,
            match.data()!.hostgf,
            match.data()!.hosttarget,
            match.data()!.hostmoves,
            match.data()!.joinmoves,
            enemy.data()!.username,
            match.data()!.jointarget,
            match.data()!.joinurl,
            match.data()!.time != null ? 1 : 0,
            match.data()!.time
        )
    } else {
        const enemy = await users.doc(match.data()!.hostuid).get()
        return new ActiveMatch(
            match.id,
            match.data()!.gfid,
            match.data()!.joingf,
            match.data()!.jointarget,
            match.data()!.joinmoves,
            match.data()!.hostmoves,
            enemy.data()!.username,
            match.data()!.hosttarget,
            match.data()!.hosturl,
            match.data()!.time != null ? 1 : 0,
            match.data()!.time
        )
    }
}

async function deleteReference(userId: string, oldReference: string) {
    console.error(
        Error(
            'active match ${doc.id} doesnt exist for ${userId}. Deleting reference from user/activematches'
        )
    )
    await users
        .doc(userId)
        .collection('activematches')
        .doc(oldReference)
        .delete()
}
