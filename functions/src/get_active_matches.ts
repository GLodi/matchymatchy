import * as admin from "firebase-admin";
import { QuerySnapshot } from "@google-cloud/firestore";
import { ActiveMatch } from "./models/active_match";

const matches = admin.firestore().collection("matches");
const users = admin.firestore().collection("users");

export async function getActiveMatches(request: any, response: any) {
  const userId: string = request.query.userId;
  try {
    const activeMatchesQuery = await users
      .doc(userId)
      .collection("activematches")
      .get();
    if (!activeMatchesQuery.empty) {
      const activeMatches: ActiveMatch[] = await makeList(
        userId,
        activeMatchesQuery
      );
      response.send(activeMatches);
    } else {
      response.send([]);
    }
  } catch (e) {
    console.log("--- error getting matches player");
    console.error(Error(e));
    response.status(500).send("Error retrieving active matches information");
  }
}

async function makeList(
  userId: string,
  activeMatchesQuery: QuerySnapshot
): Promise<ActiveMatch[]> {
  const list: ActiveMatch[] = [];
  for (const doc of activeMatchesQuery.docs) {
    const match = await matches.doc(doc.id).get();
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
          match.data()!.joinurl,
          match.data()!.time != null ? 1 : 0
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
          match.data()!.hosturl,
          match.data()!.time != null ? 1 : 0
        )
      );
    }
  }
  return list;
}
