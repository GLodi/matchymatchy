import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {

  Future<GameField> getDb();

  /// Signal backend that player is available to play.
  Future<void> queuePlayer();

}

class ApiProviderImpl implements ApiProvider {

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefields');

  CollectionReference get queueRef =>
      Firestore.instance.collection('queue');
  
  @override
  Future<GameField> getDb() async {
    return gameFieldRef.getDocuments().then((qs) =>
        GameField.fromMap(qs.documents.first.data));
  }

  void prova() async {
    Firestore.instance.runTransaction((transactionHandler) async {
      await transactionHandler.set(gameFieldRef.document(), {
            'id': 2,
            'grid': '0123401234012340123401234',
            'target' : '111111111',
        },
      );
    });
  }

  @override
  Future<void> queuePlayer() {

    // Future has to return void, otherwise callers can't await on it.
    return null;
  }
  
}