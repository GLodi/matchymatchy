import 'net_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {

  Future<GameField> getDb();

}

class ApiProviderImpl implements ApiProvider {
  final NetUtils _net;

  ApiProviderImpl(this._net);
  
  CollectionReference get gameFieldsRef =>
      Firestore.instance.collection('gamefields');

  CollectionReference get matchesRef =>
      Firestore.instance.collection('matches');
  
  @override
  Future<GameField> getDb() async {
    return gameFieldsRef.getDocuments().then((qs) =>
        GameField.fromMap(qs.documents.first.data));
  }
  
}