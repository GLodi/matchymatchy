import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  Future<User> getUser(String uid);

  Future<List<MatchOnline>> getMatchHistory(String uid);

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
  Future<List<MatchOnline>> getMatchHistory(String uid) async {
    List<MatchOnline> list = List<MatchOnline>();
    QuerySnapshot matchesQuery =
        await usersRef.document(uid).collection('matches').getDocuments();
    print('documenti: ' + matchesQuery.documents.length.toString());
    await matchesQuery.documents.forEach((d) async {
      DocumentReference matchRef = d.data['match'];
      DocumentSnapshot matchSnap = await matchRef.get();
      print('snap' + matchSnap.data.toString());
      print('bbbbb');
      // TODO: rename MatchOnline => Situation/CurrentMatch
      // TODO: create MatchOnline with just archive information
      MatchOnline matchOnline = MatchOnline.fromMap(matchSnap.data);
      print('matchOnline' + matchOnline.toMap().toString());
      list.add(matchOnline);
    });
    print('list length' + list.length.toString());
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
