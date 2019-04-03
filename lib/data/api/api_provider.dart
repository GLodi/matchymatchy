import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  // Returns GameField and TargetField with given id
  Future<Game> getGame(int id);

  // Add player to server queue
  Future<String> queuePlayer(String uid);

  // Subscribes to EnemyField changes
  Future<MatchUpdate> listenToMatchUpdates(String matchId);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefields');

  CollectionReference get queueRef => Firestore.instance.collection('queue');

  CollectionReference get matchesRef =>
      Firestore.instance.collection('matches');

  @override
  Future<Game> getGame(int id) async {
    return gameFieldRef.document(id.toString()).get().then((doc) {
      doc.data['_id'] = id;
      return Game.fromMap(doc.data);
    });
  }

  @override
  Future<String> queuePlayer(String uid) async {
    // TODO listen to changes in document for start of game
    return await _net
        .get(baseUrl + 'queuePlayer?userId=' + uid)
        .then((response) => response);
  }

  @override
  Future<MatchUpdate> listenToMatchUpdates(String matchId) async {
    return matchesRef
        .document(matchId)
        .snapshots()
        .listen((snapshot) => MatchUpdate.fromMap(snapshot.data))
        .asFuture();
  }
}
