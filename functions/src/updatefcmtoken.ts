import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";
import { DocumentSnapshot } from "@google-cloud/firestore";

let users = admin.firestore().collection("users");
let matches = admin.firestore().collection("matches");

async function updateFcmToken(userId: string, userFcmToken: string) {
  const userDoc: DocumentSnapshot = await users.doc(userId).get();
  if (userDoc.data()!.fcmtoken != userFcmToken) {
    users.doc(userId).update({ fcmtoken: userFcmToken });
    // cycle through activematches and update token
  }
}
