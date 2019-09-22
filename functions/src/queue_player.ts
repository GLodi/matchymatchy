import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";
import {
  DocumentReference,
  DocumentSnapshot,
  QueryDocumentSnapshot,
  QuerySnapshot
} from "@google-cloud/firestore";

let users = admin.firestore().collection("users");
let queue = admin.firestore().collection("queue");
let gamefields = admin.firestore().collection("gamefields");
let matches = admin.firestore().collection("matches");

/**
 * Queue player in a new match
 */
export async function queuePlayer(request: any, response: any) {
  let userId: string = request.query.userId;
  let userFcmToken: string = request.query.userFcmToken;
  try {
    // TODO: update all active matches with new fcmtoken
    let match: ActiveMatch = await newGame(userId, userFcmToken);
    response.send(match);
  } catch (e) {
    console.log("--- error queueing player");
    console.error(Error(e));
    response.status(500).send("Error queueing player");
  }
}

/**
 * Host/Join game depending on queue's situation
 * Queue can either be empty or full.
 * If empty, create new element in queue and wait for someone.
 * if full, join other player's match and start game.
 */
async function newGame(
  userId: string,
  userFcmToken: string
): Promise<ActiveMatch> {
  let qs: QuerySnapshot = await queue.get();
  let gfDocMatch: [DocumentSnapshot, string] = qs.empty
    ? await queueEmpty(userId, userFcmToken)
    : await queueNotEmpty(userId, userFcmToken);
  let diff: string = await diffToSend(
    gfDocMatch[0].data()!.grid,
    gfDocMatch[0].data()!.target
  );
  let newMatch: ActiveMatch = new ActiveMatch(
    gfDocMatch[1],
    gfDocMatch[0].id,
    gfDocMatch[0].data()!.grid,
    gfDocMatch[0].data()!.target,
    0,
    0,
    "Searching...",
    diff,
    0
  );
  return newMatch;
}

/**
 * Populate queue with player's information.
 * Returns match's GameField
 */
async function queueEmpty(
  userId: string,
  userFcmToken: string
): Promise<[DocumentSnapshot, string]> {
  let gfid: number = Math.floor(Math.random() * 1000) + 1;
  let gf: DocumentSnapshot = await gamefields.doc(String(gfid)).get();
  let newMatchRef: DocumentReference = matches.doc();
  newMatchRef.set({
    gfid: +gf.id,
    hostmoves: +0,
    hostuid: userId,
    hostgf: gf.data()!.grid,
    hosttarget: await diffToSend(gf.data()!.grid, gf.data()!.target),
    hostfcmtoken: userFcmToken,
    joinmoves: +0,
    joinuid: null,
    joingf: gf.data()!.grid,
    jointarget: await diffToSend(gf.data()!.grid, gf.data()!.target),
    joinfcmtoken: null,
    winner: null,
    winnername: null,
    hostdone: null,
    joindone: null,
    forfeitwin: false
  });
  queue.add({
    uid: userId,
    gfid: +gf.id,
    matchid: newMatchRef.id,
    ufcmtoken: userFcmToken,
    time: admin.firestore.Timestamp.now()
  });
  return [gf, newMatchRef.id];
}

/**
 * Join last element in queue
 * Returns GameField of starting match.
 */
async function queueNotEmpty(
  userId: string,
  userFcmToken: string
): Promise<[DocumentSnapshot, string]> {
  let query: QuerySnapshot = await queue
    .orderBy("time", "asc")
    .limit(1)
    .get();
  let matchId: string = await delQueueStartMatch(
    query.docs[0],
    userId,
    userFcmToken
  );
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  let hostRef: DocumentReference = await users.doc(matchDoc.data()!.hostuid);
  let joinRef: DocumentReference = await users.doc(matchDoc.data()!.joinuid);
  hostRef
    .collection("activematches")
    .doc(matchDoc.id)
    .set({});
  joinRef
    .collection("activematches")
    .doc(matchDoc.id)
    .set({});
  let gf: DocumentSnapshot = await gamefields
    .doc(String(matchDoc.data()!.gfid))
    .get();
  return [gf, matchId];
}

/**
 * Delete queue element and start match
 */
async function delQueueStartMatch(
  doc: QueryDocumentSnapshot,
  joinUid: string,
  joinFcmToken: string
): Promise<string> {
  queue.doc(doc.id).delete();
  let matchId: string = doc.data().matchid;
  await matches.doc(matchId).update({
    hostmoves: 0,
    joinmoves: 0,
    joinuid: joinUid,
    joinfcmtoken: joinFcmToken,
    time: admin.firestore.Timestamp.now()
  });
  return matchId;
}

function diffToSend(gf: string, target: string): string {
  let enemy = "";
  var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
  for (let i = 0; i < 9; i++) {
    if (gf[a[i]] == target[i]) enemy += gf[a[i]];
    else enemy += "6";
  }
  return enemy;
}
