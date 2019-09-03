import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  Future<User> getUser(String uid);

  Future<List<ActiveMatch>> getActiveMatches(String uid);

  Future<List<PastMatch>> getPastMatches(String uid);

  Future<ActiveMatch> queuePlayer(String uid, String token);

  Future<bool> sendMove(
      ActiveMatch activeMatch, String newTarget, String uid, bool done);

  Future<bool> sendForfeit(String uid, String matchId);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final _baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

  CollectionReference get usersRef => Firestore.instance.collection('users');

  @override
  Future<User> getUser(String uid) {
    return usersRef.document(uid).get().then((doc) => User.fromMap(doc.data));
  }

  @override
  Future<List<ActiveMatch>> getActiveMatches(String uid) async {
    return _net
        .get(_baseUrl + 'getActiveMatches?userId=' + uid)
        .then((response) {
      print(response);
    });
  }

  @override
  Future<List<PastMatch>> getPastMatches(String uid) async {
    List<PastMatch> list = List<PastMatch>();
    QuerySnapshot pastMatchesQuery =
        await usersRef.document(uid).collection('pastmatches').getDocuments();
    print('past matches detected: ' +
        pastMatchesQuery.documents.length.toString());
    pastMatchesQuery.documents.forEach((d) {
      print('data' + d.data.toString());
      list.add(PastMatch.fromMap(d.data));
    });
    print('past matches list length' + list.length.toString());
    return list;
  }

  @override
  Future<ActiveMatch> queuePlayer(String uid, String token) async {
    return _net
        .get(_baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .then((response) {
      print(response);
      return ActiveMatch.fromMap(response);
    });
  }

  @override
  Future<bool> sendMove(
      ActiveMatch activeMatch, String newTarget, String uid, bool done) async {
    return _net
        .get(_baseUrl +
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
    return _net
        .get(_baseUrl + 'forfeit?userId=' + uid + '&matchId=' + matchId)
        .then((response) => response);
  }
}
