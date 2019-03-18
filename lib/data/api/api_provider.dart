import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {

  // Returns GameField and TargetField with given id.
  Future<Game> getGame(int id);

  // Add player to server queue.
  Future<void> queuePlayer();

}

class ApiProviderImpl implements ApiProvider {

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefields');

  CollectionReference get queueRef =>
      Firestore.instance.collection('queue');
  
  @override
  Future<Game> getGame(int id) async {
    return gameFieldRef.document(id.toString()).get()
      .then((doc) {
        doc.data['_id'] = id;
        return Game.fromMap(doc.data);
      });
  }

  @override
  Future<void> queuePlayer() async {
    return Firestore.instance.runTransaction((transactionHandler) async {
      await transactionHandler.set(queueRef.document(FieldValueType.serverTimestamp.toString()), {
            'userId': '0123401234012340123401234',
        },
      );
    });
  }
  
}