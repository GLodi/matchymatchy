import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  // Returns GameField and TargetField with given id
  Future<Game> getGame(int id);

  // Add player to server queue
  Future<Game> queuePlayer(String uid, String token);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

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
        .get(baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .then((response) => Game.fromMap(response));
  }
}
