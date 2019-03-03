import 'net_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiRepo {

  Future<GameField> getDb();

}

class ApiRepoImpl implements ApiRepo {
  final NetUtils _net;

  ApiRepoImpl(this._net);
  
  CollectionReference get gameFieldsRef =>
      Firestore.instance.collection('gamefields');
  
  @override
  Future<GameField> getDb() async {
    return gameFieldsRef.getDocuments().then((qs) =>
        GameField.fromMap(qs.documents.first.data));
  }
  
}