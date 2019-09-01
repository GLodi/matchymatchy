import * as admin from "firebase-admin";

let matches = admin.firestore().collection("matches");
let users = admin.firestore().collection("users");

export async function getActiveMatches(request: any, response: any) {
  let userId: string = request.query.userId;
  try {
    let list;
    let docs = await users
      .doc(userId)
      .collection("activematches")
      .get();
    await docs.forEach(async d => {
      let match = await matches.doc(d.id).get();
      list.push(match.data());
    });
  } catch (e) {
    console.log("--- error getting matches player");
    console.log(e);
    response.send(false);
  }
}
