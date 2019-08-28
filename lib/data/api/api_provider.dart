import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  Future<User> getUser(String uid);

  Future<List<MatchOnline>> getActiveMatches(String uid);

  Future<List<PastMatch>> getPastMatches(String uid);

  Future<MatchOnline> queuePlayer(String uid, String token);

  Future<bool> sendMove(Session session, bool done);

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
  Future<List<MatchOnline>> getActiveMatches(String uid) async {
    List<MatchOnline> list = List<MatchOnline>();
    QuerySnapshot activeMatchesQuery =
        await usersRef.document(uid).collection('activematches').getDocuments();
    print('active matches detected: ' +
        activeMatchesQuery.documents.length.toString());
    activeMatchesQuery.documents
        .forEach((d) => list.add(MatchOnline.fromMap(d.data)));
    print('active matches list length' + list.length.toString());
    return list;
  }

  @override
  Future<List<PastMatch>> getPastMatches(String uid) async {
    List<PastMatch> list = List<PastMatch>();
    QuerySnapshot pastMatchesQuery =
        await usersRef.document(uid).collection('pastmatches').getDocuments();
    print('past matches detected: ' +
        pastMatchesQuery.documents.length.toString());
    pastMatchesQuery.documents
        .forEach((d) => list.add(PastMatch.fromMap(d.data)));
    print('past matches list length' + list.length.toString());
    return list;
  }

  @override
  Future<MatchOnline> queuePlayer(String uid, String token) async {
    return _net
        .get(_baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .then((response) {
      print(response);
      return MatchOnline.fromMap(response);
    });
  }

  @override
  Future<bool> sendMove(Session session, bool done) async {
    return _net
        .get(_baseUrl +
            'playMove?userId=' +
            session.uid +
            '&matchId=' +
            session.matchId +
            '&newGf=' +
            session.gf +
            '&newTarget=' +
            session.target +
            '&done=' +
            done.toString() +
            '&moves=' +
            session.moves.toString())
        .then((response) => response);
  }

  @override
  Future<bool> sendForfeit(String uid, String matchId) async {
    return _net
        .get(_baseUrl + 'forfeit?userId=' + uid + '&matchId=' + matchId)
        .then((response) => response);
  }
}
