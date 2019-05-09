import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:squazzle/data/models/models.dart';

import 'net_utils.dart';

abstract class ApiProvider {
  // Add player to server queue
  Future<Game> queuePlayer(String uid, String token);

  // Send updated target to server
  Future<bool> sendNewTarget(TargetField target, String uid, String matchId);

  // Send win signal to server
  Future<bool> sendWinSignal(String uid, String matchId, int moves);

  // Request user info
  Future<User> getUser(String uid);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final _baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefields');

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

  // TODO put newTarget and winSignal together
  @override
  Future<bool> sendNewTarget(
      TargetField target, String uid, String matchId) async {
    return _net
        .get(_baseUrl +
            'playMove?userId=' +
            uid +
            '&matchId=' +
            matchId +
            '&newTarget=' +
            // TODO add won or not
            // TODO add moves
            target.grid)
        .then((response) => response);
  }

  @override
  Future<bool> sendWinSignal(String uid, String matchId, int moves) {
    return _net
        .get(_baseUrl +
            'winSignal?userId=' +
            uid +
            '&matchId=' +
            matchId +
            '&moves=' +
            moves.toString())
        .then((response) => response);
  }
}
