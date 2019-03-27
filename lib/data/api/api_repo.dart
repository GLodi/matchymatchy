import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiRepo {
  // Returns GameField and TargetField with given id
  Future<Game> getGame(int id);

  // Add player to server queue with GameField id
  Future<void> queuePlayer(String uid);

  // Subscribes to EnemyField changes
  Future<EnemyField> getEnemyField(int matchId);
}

class ApiRepoImpl implements ApiRepo {
  final _net = NetUtils();
  final baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net';

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
  Future<void> queuePlayer(String uid) async {
    var a = await _net.get(baseUrl + '/queuePlayer');
    var sdf = 0;
  }

  @override
  Future<EnemyField> getEnemyField(int matchId) {
    return matchesRef
        .document(matchId.toString())
        .snapshots()
        .listen((ds) => EnemyField.fromMap(ds.data))
        .asFuture();
  }
}
