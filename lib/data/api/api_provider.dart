import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:matchymatchy/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  Future<User> getUser(String uid);

  Future<List<ActiveMatch>> getActiveMatches(String uid);

  Future<PastMatch> getPastMatch(String uid, String matchId);

  Future<List<PastMatch>> getPastMatches(String uid);

  Future<ActiveMatch> queuePlayer(String uid, String token);

  Future<bool> sendMove(
      ActiveMatch activeMatch, String newTarget, String uid, bool done);

  Future<bool> sendForfeit(String uid, String matchId);

  Future<ActiveMatch> reconnect(String uid, String token, String matchId);
}

class ApiProviderImpl implements ApiProvider {
  final _baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

  CollectionReference get usersRef => Firestore.instance.collection('users');

  @override
  Future<User> getUser(String uid) {
    return usersRef.document(uid).get().then((doc) => User.fromMap(doc.data));
  }

  @override
  Future<List<ActiveMatch>> getActiveMatches(String uid) async {
    return NetUtils.get(_baseUrl + 'getActiveMatches?userId=' + uid).then(
        (response) =>
            (response as List).map((i) => ActiveMatch.fromMap(i)).toList());
  }

  @override
  Future<PastMatch> getPastMatch(String uid, String matchId) async {
    DocumentSnapshot pastSnap = await usersRef
        .document(uid)
        .collection('pastmatches')
        .document(matchId)
        .get();
    return PastMatch.fromMap(pastSnap.data);
  }

  @override
  Future<List<PastMatch>> getPastMatches(String uid) async {
    List<PastMatch> list = List<PastMatch>();
    QuerySnapshot pastMatchesQuery =
        await usersRef.document(uid).collection('pastmatches').getDocuments();
    if (pastMatchesQuery.documents.isNotEmpty) {
      pastMatchesQuery.documents.forEach((d) {
        list.add(PastMatch.fromMap(d.data));
      });
    }
    return list;
  }

  @override
  Future<ActiveMatch> queuePlayer(String uid, String token) async {
    return NetUtils.get(
            _baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .then((response) => ActiveMatch.fromMap(response));
  }

  @override
  Future<bool> sendMove(
      ActiveMatch activeMatch, String newTarget, String uid, bool done) async {
    return NetUtils.get(_baseUrl +
            'playMove?userId=' +
            uid +
            '&matchId=' +
            activeMatch.matchId +
            '&newGf=' +
            activeMatch.gameField.grid +
            '&newTarget=' +
            newTarget +
            '&done=' +
            done.toString() +
            '&moves=' +
            activeMatch.moves.toString())
        .then((response) => response);
  }

  @override
  Future<bool> sendForfeit(String uid, String matchId) async {
    return NetUtils.get(
            _baseUrl + 'forfeit?userId=' + uid + '&matchId=' + matchId)
        .then((response) => response);
  }

  @override
  Future<ActiveMatch> reconnect(
      String uid, String token, String matchId) async {
    return NetUtils.get(_baseUrl +
            'reconnect?userId=' +
            uid +
            '&userFcmToken=' +
            token +
            '&matchId=' +
            matchId)
        .then((response) => ActiveMatch.fromMap(response));
  }
}
