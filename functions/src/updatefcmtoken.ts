import * as admin from "firebase-admin";
import { DocumentSnapshot } from "@google-cloud/firestore";

let users = admin.firestore().collection("users");

export async function updateFcmToken(userId: string, userFcmToken: string) {
  const userDoc: DocumentSnapshot = await users.doc(userId).get();
  if (userDoc.data()!.fcmtoken != userFcmToken) {
    users.doc(userId).update({ fcmtoken: userFcmToken });
  }
}
