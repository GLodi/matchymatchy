import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:squazzle/data/models/models.dart';

import 'net_utils.dart';

abstract class ApiProvider {
  // Request user info
  Future<User> getUser(String uid);

  // Add player to server queue
  Future<Game> queuePlayer(String uid, String token);

  // Send updated target to server
  Future<bool> sendMove(
      TargetField target, String uid, String matchId, String won, int moves);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final _baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

  CollectionReference get queueRef => Firestore.instance.collection('queue');

  CollectionReference get usersRef => Firestore.instance.collection('users');

  @override
  Future<User> getUser(String uid) {
    return usersRef.document(uid).get().then((doc) => User.fromMap(doc.data));
  }

  @override
  Future<Game> queuePlayer(String uid, String token) async {
    return _net
        .get(_baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .then((response) => Game.fromMap(response));
  }

  @override
  Future<bool> sendMove(TargetField target, String uid, String matchId,
      String won, int moves) async {
    return _net
        .get(_baseUrl +
            'playMove?userId=' +
            uid +
            '&matchId=' +
            matchId +
            '&newTarget=' +
            target.grid +
            '&won=' +
            won +
            '&moves=' +
            moves.toString())
        .then((response) => response);
  }
}
