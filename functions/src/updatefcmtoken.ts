import * as admin from 'firebase-admin'
import { DataNotAvailableError } from './models/exceptions'
import { DocumentSnapshot } from '@google-cloud/firestore'

let users = admin.firestore().collection('users')

export async function updateFcmToken(userId: string, userFcmToken: string) {
    const userDoc: DocumentSnapshot = await users.doc(userId).get()
    if (!userDoc.exists) throw new DataNotAvailableError()
    if (userDoc.data()!.fcmtoken != userFcmToken) {
        users.doc(userId).update({ fcmtoken: userFcmToken })
    }
}
