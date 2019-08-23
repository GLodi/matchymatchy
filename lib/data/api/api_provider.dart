import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  // Request user info
  Future<User> getUser(String uid);

  // Request list of all previously played matches
  Future<List<MatchOnline>> getMatchHistory(String uid);

  // Add player to server queue, or receive current match
  Future<MatchOnline> queuePlayer(String uid, String token);

  // Send updated target to server
  Future<bool> sendMove(Session session, bool done);

  // Send forfeit notice
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
  Future<List<MatchOnline>> getMatchHistory(String uid) async {
    List<MatchOnline> list = List<MatchOnline>();
    QuerySnapshot matchesQuery =
        await usersRef.document(uid).collection('matches').getDocuments();
    matchesQuery.documents
        .forEach((d) => list.add(MatchOnline.fromMap(d.data)));
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
