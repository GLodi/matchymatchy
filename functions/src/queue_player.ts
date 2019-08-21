import * as admin from "firebase-admin";
import { Session } from "./session";
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
 * Queue handling
 * Waits for a player's connection: checks if he's currently
 * playing in a match (if which case it sends him the current
 * match's situation) or he's ready for a new game.
 */
export async function queuePlayer(request: any, response: any) {
  let userId: string = request.query.userId;
  let userFcmToken: string = request.query.userFcmToken;
  try {
    let currentMatch: string = await alreadyInMatch(userId);
    if (currentMatch == null) {
      response.send(await newGame(userId, userFcmToken));
    } else {
      response.send(await reconnect(userId, userFcmToken, currentMatch));
    }
  } catch (e) {
    console.log("--- error queueing player");
    console.log(e);
    response.send(false);
  }
}

/**
 * Checks whether player is registered in a running match, if so
 * return match's id
 */
async function alreadyInMatch(userId: string): Promise<string> {
  let user: DocumentSnapshot = await users.doc(userId).get();
  return user.data()!.currentMatch != null ? user.data()!.currentMatch : null;
}

/**
 * Host/Join game depending on queue's situation
 * Queue can either be empty or full.
 * If empty, create new element in queue and wait for someone.
 * if full, join other player's match and start game.
 */
async function newGame(userId: string, userFcmToken: string): Promise<Session> {
  let qs: QuerySnapshot = await queue.get();
  let gfDocMatch: [DocumentSnapshot, string] = qs.empty
    ? await queueEmpty(userId, userFcmToken)
    : await queueNotEmpty(userId, userFcmToken);
  let diff: string = await diffToSend(
    gfDocMatch[0].data()!.grid,
    gfDocMatch[0].data()!.target
  );
  let newMatch: Session = new Session(
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
 * Send player info on his current running match
 */
async function reconnect(
  userId: string,
  userFcmToken: string,
  currentMatch: string
): Promise<Session> {
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
  if (matchDoc.data()!.joinuid != null) {
    return new Session(
      currentMatch,
      gfDoc.id,
      hostOrJoin ? matchDoc.data()!.hostgf : matchDoc.data()!.joingf,
      gfDoc.data()!.target,
      hostOrJoin ? matchDoc.data()!.hostmoves : matchDoc.data()!.joinmoves,
      hostOrJoin ? matchDoc.data()!.joinmoves : matchDoc.data()!.hostmoves,
      hostOrJoin
        ? await getUsername(matchDoc.data()!.joinuid)
        : await getUsername(matchDoc.data()!.hostuid),
      hostOrJoin ? matchDoc.data()!.jointarget : matchDoc.data()!.hosttarget,
      1
    );
  } else {
    return new Session(
      currentMatch,
      gfDoc.id,
      hostOrJoin ? matchDoc.data()!.hostgf : matchDoc.data()!.joingf,
      gfDoc.data()!.target,
      hostOrJoin ? matchDoc.data()!.hostmoves : matchDoc.data()!.joinmoves,
      hostOrJoin ? matchDoc.data()!.joinmoves : matchDoc.data()!.hostmoves,
      "Searching...",
      hostOrJoin ? matchDoc.data()!.jointarget : matchDoc.data()!.hosttarget,
      0
    );
  }
}

async function getUsername(userId: string): Promise<string> {
  let user: DocumentSnapshot = await users.doc(userId).get();
  return user.data()!.username;
}

/**
 * Populate queue with player's information.
 * Returns GameField of starting match.
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
    winnerName: null,
    hostdone: null,
    joindone: null,
    forfeitWin: false
  });
  queue.add({
    uid: userId,
    gfid: +gf.id,
    matchid: newMatchRef.id,
    ufcmtoken: userFcmToken,
    time: admin.firestore.Timestamp.now()
  });
  users.doc(userId).update({
    currentMatch: newMatchRef.id
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
  let match: DocumentSnapshot = await matches.doc(matchId).get();
  users.doc(userId).update({
    currentMatch: match.id
  });
  let gf: DocumentSnapshot = await gamefields
    .doc(String(match.data()!.gfid))
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

async function diffToSend(gf: string, target: string): Promise<string> {
  let enemy = "";
  var a = [6, 7, 8, 11, 12, 13, 16, 17, 18];
  for (let i = 0; i < 9; i++) {
    if (gf[a[i]] == target[i]) enemy += gf[a[i]];
    else enemy += "6";
  }
  return enemy;
}
