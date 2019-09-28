import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";
import { updateFcmToken } from "./updatefcmtoken";
import { DocumentSnapshot } from "@google-cloud/firestore";

const users = admin.firestore().collection("users");
const gamefields = admin.firestore().collection("gamefields");
const matches = admin.firestore().collection("matches");

/**
 * Send player information about ongoing match
 */
export async function reconnect(request: any, response: any) {
  const userId: string = request.query.userId;
  const userFcmToken: string = request.query.userFcmToken;
  const matchId: string = request.query.matchId;
  try {
    // TODO: update all activematches with new fcmtoken
    const match: ActiveMatch = await findMatch(userId, userFcmToken, matchId);
    response.send(match);
    updateFcmToken(userId, userFcmToken);
  } catch (e) {
    console.log("--- error queueing player");
    console.error(Error(e));
    response.status(500).send("Error queueing player");
  }
}

/**
 * Find match to reconnect to
 */
async function findMatch(
  userId: string,
  userFcmToken: string,
  currentMatch: string
) {
  const matchDoc: DocumentSnapshot = await matches.doc(currentMatch).get();
  const hostOrJoin: boolean = userId == matchDoc.data()!.hostuid;
  if (hostOrJoin && matchDoc.data()!.hostfcmtoken != userFcmToken) {
    await matches.doc(currentMatch).update({
      hostfcmtoken: userFcmToken
    });
  }
  if (!hostOrJoin && matchDoc.data()!.joinfcmtoken != userFcmToken) {
    await matches.doc(currentMatch).update({
      joinfcmtoken: userFcmToken
    });
  }
  const gfDoc: DocumentSnapshot = await gamefields
    .doc(String(matchDoc.data()!.gfid))
    .get();
  const hasStarted: boolean = matchDoc.data()!.joinuid != null;
  return new ActiveMatch(
    currentMatch,
    gfDoc.id,
    hostOrJoin ? matchDoc.data()!.hostgf : matchDoc.data()!.joingf,
    gfDoc.data()!.target,
    hostOrJoin ? matchDoc.data()!.hostmoves : matchDoc.data()!.joinmoves,
    hostOrJoin ? matchDoc.data()!.joinmoves : matchDoc.data()!.hostmoves,
    hasStarted
      ? hostOrJoin
        ? await getUsername(matchDoc.data()!.joinuid)
        : await getUsername(matchDoc.data()!.hostuid)
      : "Searching...",
    hostOrJoin ? matchDoc.data()!.jointarget : matchDoc.data()!.hosttarget,
    hasStarted ? 1 : 0
  );
}

async function getUsername(userId: string): Promise<string> {
  const user: DocumentSnapshot = await users.doc(userId).get();
  return user.data()!.username;
}
