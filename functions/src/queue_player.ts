import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";
import { updateFcmToken } from "./updatefcmtoken";
import {
  DocumentReference,
  DocumentSnapshot,
  QueryDocumentSnapshot,
  QuerySnapshot
} from "@google-cloud/firestore";

const users = admin.firestore().collection("users");
const queue = admin.firestore().collection("queue");
const gamefields = admin.firestore().collection("gamefields");
const matches = admin.firestore().collection("matches");

/**
 * Queue player in a new match
 */
export async function queuePlayer(request: any, response: any) {
  const userId: string = request.query.userId;
  const userFcmToken: string = request.query.userFcmToken;
  try {
    const qs: QuerySnapshot = await queue.get();
    if (!qs.empty && qs.docs[0].get("uid") == userId) {
      // TODO: find a way to de-duplicate this
      const gfDocMatch: DocumentSnapshot = await matches
        .doc(qs.docs[0].get("matchid"))
        .get();
      const diff: string = await diffToSend(
        gfDocMatch.data()!.grid,
        gfDocMatch.data()!.target
      );
      const queueingMatch: ActiveMatch = new ActiveMatch(
        qs.docs[0].get("matchid"),
        gfDocMatch.id,
        gfDocMatch.data()!.grid,
        gfDocMatch.data()!.target,
        0,
        0,
        "Searching...",
        diff,
        "",
        0
      );
      response.send(queueingMatch);
      updateFcmToken(userId, userFcmToken);
    } else {
      const match: ActiveMatch = await newGame(userId);
      response.send(match);
    }
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
 * If full, join other player's match and start game.
 */
async function newGame(userId: string): Promise<ActiveMatch> {
  const qs: QuerySnapshot = await queue.get();
  const gfDocMatch: [DocumentSnapshot, string] = qs.empty
    ? await queueEmpty(userId)
    : await queueNotEmpty(qs, userId);
  const diff: string = await diffToSend(
    gfDocMatch[0].data()!.grid,
    gfDocMatch[0].data()!.target
  );
  const newMatch: ActiveMatch = new ActiveMatch(
    gfDocMatch[1],
    gfDocMatch[0].id,
    gfDocMatch[0].data()!.grid,
    gfDocMatch[0].data()!.target,
    0,
    0,
    "Searching...",
    diff,
    "",
    0
  );
  return newMatch;
}

/**
 * Populate queue with player's information.
 */
async function queueEmpty(userId: string): Promise<[DocumentSnapshot, string]> {
  const gfid: number = Math.floor(Math.random() * 1000) + 1;
  const gf: DocumentSnapshot = await gamefields.doc(String(gfid)).get();
  const userDoc: DocumentSnapshot = await users.doc(userId).get();
  const newMatchRef: DocumentReference = matches.doc();
  newMatchRef.set({
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
    forfeitwin: false
  });
  queue.add({
    uid: userId,
    gfid: +gf.id,
    matchid: newMatchRef.id,
    time: admin.firestore.Timestamp.now()
  });
  return [gf, newMatchRef.id];
}

/**
 * Join last element in queue
 * Returns GameField of starting match.
 */
async function queueNotEmpty(
  query: QuerySnapshot,
  userId: string
): Promise<[DocumentSnapshot, string]> {
  const matchId: string = await delQueueStartMatch(query.docs[0], userId);
  const matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  const hostRef: DocumentReference = await users.doc(matchDoc.data()!.hostuid);
  const joinRef: DocumentReference = await users.doc(matchDoc.data()!.joinuid);
  hostRef
    .collection("activematches")
    .doc(matchDoc.id)
    .set({});
  joinRef
    .collection("activematches")
    .doc(matchDoc.id)
    .set({});
  const gf: DocumentSnapshot = await gamefields
    .doc(String(matchDoc.data()!.gfid))
    .get();
  return [gf, matchId];
}

/**
 * Delete queue element and start match
 */
async function delQueueStartMatch(
  doc: QueryDocumentSnapshot,
  joinUid: string
): Promise<string> {
  queue.doc(doc.id).delete();
  const userDoc: DocumentSnapshot = await users.doc(joinUid).get();
  const matchId: string = doc.data().matchid;
  await matches.doc(matchId).update({
    hostmoves: 0,
    joinmoves: 0,
    joinuid: joinUid,
    time: admin.firestore.Timestamp.now(),
    joinurl: userDoc.data()!.photourl
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
