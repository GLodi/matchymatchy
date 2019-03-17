import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {

  Future<GameField> getRandomGameField();

  Future<void> queuePlayer();

}

class ApiProviderImpl implements ApiProvider {
  var ran = Random();

  CollectionReference get gameFieldRef =>
      Firestore.instance.collection('gamefields');

  CollectionReference get queueRef =>
      Firestore.instance.collection('queue');
  
  @override
  Future<GameField> getRandomGameField() async {
    return gameFieldRef.document((ran.nextInt(1000)+1).toString()).get().then((doc) => 
      GameField.fromMap(doc.data) // Game.fromMap
    );
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