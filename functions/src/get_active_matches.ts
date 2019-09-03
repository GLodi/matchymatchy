import * as admin from "firebase-admin";
import { ActiveMatch } from "./models/active_match";

let matches = admin.firestore().collection("matches");
let users = admin.firestore().collection("users");

export async function getActiveMatches(request: any, response: any) {
  let userId: string = request.query.userId;
  try {
    let list: ActiveMatch[];
    let docs = await users
      .doc(userId)
      .collection("activematches")
      .get();
    await docs.forEach(async d => {
      let match = await matches.doc(d.id).get();
      list.push();
    });
    response.send(list);
  } catch (e) {
    console.log("--- error getting matches player");
    console.log(e);
    response.send(false);
  }
}
