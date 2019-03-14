import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {

  Future<GameField> getDb();

  /// Signal backend that player is available to play.
  Future<void> queuePlayer();

}

class ApiProviderImpl implements ApiProvider {

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefield');

  CollectionReference get queueRef =>
      Firestore.instance.collection('queue');
  
  @override
  Future<GameField> getDb() async {
    return gameFieldRef.getDocuments().then((qs) =>
        GameField.fromMap(qs.documents.first.data));
  }

  @override
  Future<void> queuePlayer() {

    // Future has to return void, otherwise callers can't await on it.
    return null;
  }
  
}