import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp(functions.config().firebase);

import { DocumentData } from "@google-cloud/firestore";
import { playMove, forfeit } from "./play_move";
import { queuePlayer } from "./queue_player";
import { getActiveMatches } from "./get_active_matches";
import { reconnect } from "./reconnect";

exports.queuePlayer = functions
  .region("europe-west1")
  .https.onRequest(async (request, response) => queuePlayer(request, response));

exports.playMove = functions
  .region("europe-west1")
  .https.onRequest(async (request, response) => playMove(request, response));

exports.forfeit = functions
  .region("europe-west1")
  .https.onRequest(async (request, response) => forfeit(request, response));

exports.getActiveMatches = functions
  .region("europe-west1")
  .https.onRequest(async (request, response) =>
    getActiveMatches(request, response)
  );

exports.reconnect = functions
  .region("europe-west1")
  .https.onRequest(async (request, response) => reconnect(request, response));

exports.notifyUser = functions
  .region("europe-west1")
  .firestore.document("matches/{matchId}")
  .onUpdate((change, context) => {
    const newMatch = change.after.data();
    const oldMatch = change.before.data();
    if (newMatch != null && oldMatch != null) {
      if (newMatch.joinuid != oldMatch.joinuid) {
        onMatchStart(newMatch, context.params.matchId);
      }
      if (newMatch.hosttarget != oldMatch.hosttarget) {
        onMove(newMatch, context.params.matchId, true);
      }
      if (newMatch.jointarget != oldMatch.jointarget) {
        onMove(newMatch, context.params.matchId, false);
      }
      if (newMatch.winner != oldMatch.winner) {
        onWinner(newMatch, context.params.matchId);
      }
    }
    return true;
  });

const users = admin.firestore().collection("users");

async function onMatchStart(newMatch: DocumentData, matchId: string) {
  const hostDoc = await users.doc(newMatch.hostuid).get();
  const hostName = hostDoc.data()!.username;
  const joinDoc = await users.doc(newMatch.joinuid).get();
  const joinName = joinDoc.data()!.username;

  const messageToHost = {
    data: {
      matchid: matchId,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      messType: "challenge",
      enemyName: joinName
    },
    notification: {
      title: "Match started!",
      body: joinName + " challenged you!"
    }
  };
  const messageToJoin = {
    data: {
      matchid: matchId,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      messType: "challenge",
      enemyName: hostName
    },
    notification: {
      title: "Match started!",
      body: hostName + " challenged you!"
    }
  };
  const options = {
    priority: "high",
    timeToLive: 60 * 60 * 24
  };
  try {
    await admin
      .messaging()
      .sendToDevice(hostDoc.data()!.fcmtoken, messageToHost, options);
    await console.log("message sent to host: " + hostDoc.data()!.fcmtoken);
  } catch (e) {
    console.log("--- error sending message: ");
    console.error(Error(e));
  }
  try {
    admin
      .messaging()
      .sendToDevice(joinDoc.data()!.fcmtoken, messageToJoin, options);
    console.log("message sent to join: " + joinDoc.data()!.fcmtoken);
  } catch (e) {
    console.log("--- error sending message: ");
    console.error(Error(e));
  }
}

async function onMove(
  newMatch: DocumentData,
  matchId: string,
  hostOrJoin: boolean
) {
  const hostDoc = await users.doc(newMatch.hostuid).get();
  const joinDoc = await users.doc(newMatch.joinuid).get();
  const message = {
    data: {
      matchid: matchId,
      enemytarget: hostOrJoin ? newMatch.hosttarget : newMatch.jointarget,
      enemymoves: hostOrJoin
        ? newMatch.hostmoves.toString()
        : newMatch.joinmoves.toString(),
      messType: "move"
    }
  };
  const options = {
    priority: "high",
    timeToLive: 60 * 60 * 24
  };
  try {
    admin
      .messaging()
      .sendToDevice(
        hostOrJoin ? joinDoc.data()!.fcmtoken : hostDoc.data()!.fcmtoken,
        message,
        options
      );
  } catch (e) {
    console.log("--- error sending message");
    console.error(Error(e));
  }
}

async function onWinner(newMatch: DocumentData, matchId: string) {
  const hostDoc = await users.doc(newMatch.hostuid).get();
  const joinDoc = await users.doc(newMatch.joinuid).get();
  const messageToJoin = {
    data: {
      matchid: matchId,
      winner: newMatch.winner,
      messType: "winner",
      winnername: newMatch.winnername,
      forfeitwin: newMatch.forfeitwin.toString()
    },
    notification: {
      title: "Match finished!",
      body: newMatch.winnername + " won!"
    }
  };
  const messageToHost = {
    data: {
      matchid: matchId,
      winner: newMatch.winner,
      messType: "winner",
      winnername: newMatch.winnername,
      forfeitwin: newMatch.forfeitwin.toString()
    },
    notification: {
      title: "Match finished!",
      body: newMatch.winnername + " won!"
    }
  };
  const options = {
    priority: "high",
    timeToLive: 60 * 60 * 24
  };
  try {
    admin
      .messaging()
      .sendToDevice(joinDoc.data()!.fcmtoken, messageToJoin, options);
  } catch (e) {
    console.log("--- error sending message");
    console.error(Error(e));
  }
  try {
    admin
      .messaging()
      .sendToDevice(hostDoc.data()!.fcmtoken, messageToHost, options);
  } catch (e) {
    console.log("--- error sending message");
    console.error(Error(e));
  }
}
