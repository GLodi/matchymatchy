import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';
import 'net_utils.dart';

abstract class ApiProvider {
  // Returns GameField and TargetField with given id
  Future<Game> getGame(int id);

  // Add player to server queue
  Future<void> queuePlayer(String uid);

  // Subscribes to EnemyField changes
  Future<TargetField> getEnemyField(int matchId);
}

class ApiProviderImpl implements ApiProvider {
  final _net = NetUtils();
  final baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';
  bool hostOrJoin = true;

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
    await _net.get(baseUrl + 'queuePlayer?userId=' + uid);
  }

  @override
  Future<TargetField> getEnemyField(int matchId) async {
    return matchesRef.document(matchId.toString()).snapshots().listen((ds) {
      hostOrJoin
          ? ds.data['target'] = ds.data['jointarget']
          : ds.data['target'] = ds.data['hosttarget'];
      return TargetField.fromMap(ds.data);
    }).asFuture();
  }
}
