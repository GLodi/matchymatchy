import * as admin from "firebase-admin";
import { DocumentReference, DocumentSnapshot } from "@google-cloud/firestore";

let matches = admin.firestore().collection("matches");
let users = admin.firestore().collection("users");

export async function playMove(request: any, response: any) {
  let userId: string = request.query.userId;
  let matchId: string = request.query.matchId;
  let newGf: string = request.query.newGf;
  let newTarget: string = request.query.newTarget;
  let done: boolean = request.query.done == "true";
  let moves: number = +request.query.moves;
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  try {
    if (matchDoc.exists) {
      if (isPlayer(userId, matchDoc)) {
        await updateMatch(userId, matchId, newGf, newTarget, moves);
        if (done) await setPlayerDone(userId, matchId);
        response.send(true);
        if (done && isOtherPlayerDone(userId, matchDoc)) {
          await declareWinner(matchId);
        }
      } else {
        console.log("--- error user neither host nor join");
        response.send(false);
      }
    } else {
      console.log("--- error no match with specified matchId");
      response.send(false);
    }
  } catch (e) {
    console.log("--- error applying player move");
    console.log(e);
    response.send(false);
  }
}

function isPlayer(userId: string, matchDoc: DocumentSnapshot): boolean {
  return (
    userId == matchDoc.data()!.hostuid || userId == matchDoc.data()!.joinuid
  );
}

function isOtherPlayerDone(
  firstPlayer: string,
  matchDoc: DocumentSnapshot
): boolean {
  return (
    (matchDoc.data()!.hostdone != null &&
      firstPlayer == matchDoc.data()!.joinuid) ||
    (matchDoc.data()!.joindone != null &&
      firstPlayer == matchDoc.data()!.hostuid)
  );
}

export async function forfeit(request: any, response: any) {
  let userId: string = request.query.userId;
  let matchId: string = request.query.matchId;
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  try {
    if (matchDoc.exists) {
      if (matchDoc.data()!.winner == null) {
        if (userId == matchDoc.data()!.hostuid) {
          await upWinAmount(matchId, false, true);
        }
        if (userId == matchDoc.data()!.joinuid) {
          await upWinAmount(matchId, true, true);
        }
        response.send(true);
      } else {
        console.log("--- error winner already declared");
        response.send(false);
      }
    }
  } catch (e) {
    console.log("--- error forfeting player player");
    console.log(e);
    response.send(false);
  }
}

/**
 * Update match document. This change will be picked up by index.ts
 * and FCM will notify the enemy player.
 */
async function updateMatch(
  userId: string,
  matchId: string,
  newGf: string,
  newTarget: string,
  moves: number
) {
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  userId == matchDoc.data()!.hostuid
    ? await matches.doc(matchId).update({
        hostgf: newGf,
        hosttarget: newTarget,
        hostmoves: +moves
      })
    : await matches.doc(matchId).update({
        joingf: newGf,
        jointarget: newTarget,
        joinmoves: +moves
      });
}

/**
 * If a player signals that is done with the match, update the doc.
 */
async function setPlayerDone(userId: string, matchId: string) {
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  userId == matchDoc.data()!.hostuid
    ? await matches.doc(matchId).update({
        hostdone: true
      })
    : await matches.doc(matchId).update({
        joindone: true
      });
  await users.doc(userId).update({
    currentMatch: null
  });
}

/**
 * If both players are done, declare winner.
 */
async function declareWinner(matchId: string) {
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  if (matchDoc.data()!.hostmoves < matchDoc.data()!.joinmoves) {
    await upWinAmount(matchId, true, false);
  } else if (matchDoc.data()!.hostmoves > matchDoc.data()!.joinmoves) {
    await upWinAmount(matchId, false, false);
  } else {
    await matches.doc(matchId).update({
      winner: "draw"
    });
    await resetMatch(matchId);
  }
}

/**
 * Increase winner's win count.
 */
async function upWinAmount(
  matchId: string,
  hostOrJoin: boolean,
  forfeitWin: boolean
) {
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  let userRef: DocumentReference = await users.doc(
    hostOrJoin ? matchDoc.data()!.hostuid : matchDoc.data()!.joinuid
  );
  let user: DocumentSnapshot = await userRef.get();
  userRef.update({
    matchesWon: +user.data()!.matchesWon + 1
  });
  matches.doc(matchId).update({
    winner: hostOrJoin ? matchDoc.data()!.hostuid : matchDoc.data()!.joinuid,
    winnerName: user.data()!.username,
    forfeitWin: forfeitWin
  });
  await resetMatch(matchId);
}

/**
 * Frees players from finished game, allowing them to re-queue.
 * Copies match document to each user's user/matches collection and
 * deletes it from matches.
 */
async function resetMatch(matchId: string) {
  let matchDoc: DocumentSnapshot = await matches.doc(matchId).get();
  let hostRef: DocumentReference = await users.doc(matchDoc.data()!.hostuid);
  let joinRef: DocumentReference = await users.doc(matchDoc.data()!.joinuid);
  hostRef.update({
    currentMatch: null
  });
  joinRef.update({
    currentMatch: null
  });
  // TODO: following not needed, as it will only be refenced
  hostRef
    .collection("matches")
    .doc(matchId)
    .update(matchDoc);
  joinRef
    .collection("matches")
    .doc(matchId)
    .update(matchDoc);
}
