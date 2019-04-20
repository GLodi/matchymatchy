import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:squazzle/data/models/models.dart';

import 'net_utils.dart';

abstract class ApiProvider {
  // Returns GameField and TargetField with given id
  Future<Game> getGame(int id);

  // Add player to server queue
  Future<Game> queuePlayer(String uid, String token);

  // Send updated target to server
  Future<bool> sendNewTarget(TargetField target, String uid);

  // Set matchId sent through Firebase Cloud Messaging
  void setMatchId(String matchId);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final _baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';
  String _matchId;

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefields');

  CollectionReference get queueRef => Firestore.instance.collection('queue');

  @override
  Future<Game> getGame(int id) async {
    return gameFieldRef.document(id.toString()).get().then((doc) {
      doc.data['_id'] = id;
      return Game.fromMap(doc.data);
    });
  }

  @override
  Future<Game> queuePlayer(String uid, String token) async {
    return _net
        .get(_baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .then((response) => Game.fromMap(response));
  }

  @override
  Future<bool> sendNewTarget(TargetField target, String uid) async {
    return _net
        .get(_baseUrl +
            'playMove?userId=' +
            uid +
            '&matchId=' +
            _matchId +
            '&newTarget=' +
            target.grid)
        .then((response) => response);
  }

  @override
  void setMatchId(String matchId) {
    this._matchId = matchId;
  }
}
