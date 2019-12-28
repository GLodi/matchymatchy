import * as admin from 'firebase-admin'
import { ActiveMatch } from './models/active_match'
import { DataNotAvailableError } from './models/exceptions'
import { DocumentSnapshot } from '@google-cloud/firestore'
import { updateFcmToken } from './updatefcmtoken'

const users = admin.firestore().collection('users')
const gamefields = admin.firestore().collection('gamefields')
const matches = admin.firestore().collection('matches')

export async function reconnect(request: any, response: any) {
    const userId: string = request.query.userId
    const userFcmToken: string = request.query.userFcmToken
    const matchId: string = request.query.matchId
    try {
        updateFcmToken(userId, userFcmToken)
        const match: ActiveMatch = await findMatch(userId, matchId)
        response.send(match)
    } catch (e) {
        if (e instanceof DataNotAvailableError) {
            response.status(204).send()
        } else {
            console.log('--- error reconnecting player')
            console.error(Error(e))
            response.status(500).send()
        }
    }
}

async function findMatch(
    userId: string,
    matchId: string
): Promise<ActiveMatch> {
    const matchDoc: DocumentSnapshot = await matches.doc(matchId).get()
    if (!matchDoc.exists) throw new DataNotAvailableError() // TODO: don't throw, check if match was won
    const hostOrJoin: boolean = userId == matchDoc.data()!.hostuid
    const gfDoc: DocumentSnapshot = await gamefields
        .doc(String(matchDoc.data()!.gfid))
        .get()
    const hasStarted: boolean = matchDoc.data()!.joinuid != null
    return new ActiveMatch(
        matchId,
        gfDoc.id,
        hostOrJoin ? matchDoc.data()!.hostgf : matchDoc.data()!.joingf,
        gfDoc.data()!.target,
        hostOrJoin ? matchDoc.data()!.hostmoves : matchDoc.data()!.joinmoves,
        hostOrJoin ? matchDoc.data()!.joinmoves : matchDoc.data()!.hostmoves,
        hasStarted
            ? hostOrJoin
                ? await getUsername(matchDoc.data()!.joinuid)
                : await getUsername(matchDoc.data()!.hostuid)
            : 'Searching...',
        hostOrJoin ? matchDoc.data()!.jointarget : matchDoc.data()!.hosttarget,
        hostOrJoin ? matchDoc.data()!.joinurl : matchDoc.data()!.hosturl,
        hasStarted ? 1 : 0,
        hostOrJoin ? +matchDoc.data()!.hostdone : +matchDoc.data()!.joindone,
        hostOrJoin ? +matchDoc.data()!.joindone : +matchDoc.data()!.hostdone,
        userId == matchDoc.data()!.hostuid ? 1 : 0,
        0,
        matchDoc.data()!.time
    )
}

async function getUsername(userId: string): Promise<string> {
    const user: DocumentSnapshot = await users.doc(userId).get()
    return user.data()!.username
}
