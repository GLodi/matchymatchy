import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";

let matches = admin.firestore().collection("matches");
let users = admin.firestore().collection("users");

export async function getActiveMatches(request: any, response: any) {
  let userId: string = request.query.userId;
  try {
    let list: ActiveMatch[] = [];
    let docs = await users
      .doc(userId)
      .collection("activematches")
      .get();
    // Following line returns forEach on null error,
    // that's because there are no docs in user/activematch
    await docs.forEach(async d => {
      let match = await matches.doc(d.id).get();
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
    });
    response.send(list);
  } catch (e) {
    console.log("--- error getting matches player");
    console.log(e);
    response.send(false);
  }
}
