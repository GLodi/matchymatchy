import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {
  // Returns GameField and TargetField with given id
  Future<Game> getGame(int id);

  // Add player to server queue with GameField id
  Future<void> queuePlayer(int uid, int gfid, int matchId);

  // Subscribes to EnemyField changes
  Future<EnemyField> getEnemyField(int matchId);
}

class ApiProviderImpl implements ApiProvider {
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
  Future<void> queuePlayer(int uid, int gfid, int matchId) async {
    return Firestore.instance.runTransaction((transactionHandler) async {
      await transactionHandler.set(
        queueRef.document(FieldValueType.serverTimestamp.toString()),
        {
          'time': '${FieldValueType.serverTimestamp.toString()}',
          'uid': uid,
          'gfid': gfid,
          'matchid': matchId,
        },
      );
    });
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
