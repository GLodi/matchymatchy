import * as admin from "firebase-admin";
import { QuerySnapshot } from "@google-cloud/firestore";
import { ActiveMatch } from "./models/active_match";

let matches = admin.firestore().collection("matches");
let users = admin.firestore().collection("users");

export async function getActiveMatches(request: any, response: any) {
  let userId: string = request.query.userId;
  try {
    let docs = await users
      .doc(userId)
      .collection("activematches")
      .get();
    if (!docs.empty) {
      let activeMatches: ActiveMatch[] = await makeList(userId, docs);
      response.send(activeMatches);
    } else {
      response.status(500).send("No active matches");
    }
  } catch (e) {
    console.log("--- error getting matches player");
    console.error(e);
    response.status(500).send("Error retrieving active matches information");
  }
}

async function makeList(
  userId: string,
  query: QuerySnapshot
): Promise<ActiveMatch[]> {
  let list: ActiveMatch[] = [];
  for (let doc of query.docs) {
    let match = await matches.doc(doc.id).get();
    if (userId == match.data()!.hostuid) {
      list.push(
        new ActiveMatch(
          match.id,
          match.data()!.gfid,
          match.data()!.hostgf,
          match.data()!.hosttarget,
          match.data()!.hostmoves,
          match.data()!.joinmoves,
          match.data()!.joinname,
          match.data()!.jointarget,
          match.data()!.started
        )
      );
    } else {
      list.push(
        new ActiveMatch(
          match.id,
          match.data()!.gfid,
          match.data()!.joingf,
          match.data()!.jointarget,
          match.data()!.joinmoves,
          match.data()!.hostmoves,
          match.data()!.hostname,
          match.data()!.hosttarget,
          match.data()!.started
        )
      );
    }
  }
  return list;
}
