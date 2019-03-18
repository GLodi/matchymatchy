import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {

  // Returns GameField and TargetField with given id.
  Future<Game> getGame(int id);

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
      .then((doc) => Game.fromMap(doc.data));
  }

  @override
  Future<void> queuePlayer() async {
    return Firestore.instance.runTransaction((transactionHandler) async {
      await transactionHandler.set(queueRef.document(DateTime.now().millisecondsSinceEpoch.toString()), {
            'userId': '0123401234012340123401234',
        },
      );
    });
  }
  
}