import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";
import { DocumentSnapshot } from "@google-cloud/firestore";

let users = admin.firestore().collection("users");
let gamefields = admin.firestore().collection("gamefields");
let matches = admin.firestore().collection("matches");

/**
 * Send player information about ongoing match
 */
export async function reconnect(request: any, response: any) {
  let userId: string = request.query.userId;
  let userFcmToken: string = request.query.userFcmToken;
  let matchId: string = request.query.matchId;
  try {
    // TODO: update all activematches with new fcmtoken
    let match: ActiveMatch = await findMatch(userId, userFcmToken, matchId);
    response.send(match);
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
  let matchDoc: DocumentSnapshot = await matches.doc(currentMatch).get();
  let hostOrJoin: boolean = userId == matchDoc.data()!.hostuid;
  hostOrJoin
    ? await matches.doc(currentMatch).update({
        hostfcmtoken: userFcmToken
      })
    : await matches.doc(currentMatch).update({
        joinfcmtoken: userFcmToken
      });
  let gfDoc: DocumentSnapshot = await gamefields
    .doc(String(matchDoc.data()!.gfid))
    .get();
  let hasStarted: boolean = matchDoc.data()!.joinuid != null;
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
  let user: DocumentSnapshot = await users.doc(userId).get();
  return user.data()!.username;
}
