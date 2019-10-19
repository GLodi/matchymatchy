import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:squazzle/data/models/models.dart';

abstract class ApiProvider {
  Future<User> getUser(String uid);

  Future<List<ActiveMatch>> getActiveMatches(String uid);

  Future<List<PastMatch>> getPastMatches(String uid);

  Future<ActiveMatch> queuePlayer(String uid, String token);

  Future<bool> sendMove(
      ActiveMatch activeMatch, String newTarget, String uid, bool done);

  Future<bool> sendForfeit(String uid, String matchId);

  Future<ActiveMatch> reconnect(String uid, String token, String matchId);
}

class ApiProviderImpl implements ApiProvider {
  final _client = Dio();
  final _baseUrl = 'https://europe-west1-squazzle-40ea9.cloudfunctions.net/';

  CollectionReference get usersRef => Firestore.instance.collection('users');

  @override
  Future<User> getUser(String uid) {
    return usersRef.document(uid).get().then((doc) => User.fromMap(doc.data));
  }

  @override
  Future<List<ActiveMatch>> getActiveMatches(String uid) async {
    return _client
        .get(_baseUrl + 'getActiveMatches?userId=' + uid)
        .catchError((e) => throw e)
        .then((response) => (response.data as List)
            .map((i) => ActiveMatch.fromMap(i))
            .toList());
  }

  @override
  Future<List<PastMatch>> getPastMatches(String uid) async {
    List<PastMatch> list = List<PastMatch>();
    QuerySnapshot pastMatchesQuery =
        await usersRef.document(uid).collection('pastmatches').getDocuments();
    if (pastMatchesQuery.documents.isNotEmpty) {
      pastMatchesQuery.documents.forEach((d) {
        list.add(PastMatch.fromMap(d.data));
      });
    }
    return list;
  }

  @override
  Future<ActiveMatch> queuePlayer(String uid, String token) async {
    return _client
        .get(_baseUrl + 'queuePlayer?userId=' + uid + '&userFcmToken=' + token)
        .catchError((e) => throw e)
        .then((response) => ActiveMatch.fromMap(response.data));
  }

  @override
  Future<bool> sendMove(
      ActiveMatch activeMatch, String newTarget, String uid, bool done) async {
    return _client
        .get(_baseUrl +
            'playMove?userId=' +
            uid +
            '&matchId=' +
            activeMatch.matchId +
            '&newGf=' +
            activeMatch.gameField.grid +
            '&newTarget=' +
            newTarget +
            '&done=' +
            done.toString() +
            '&moves=' +
            activeMatch.moves.toString())
        .catchError((e) => throw e)
        .then((response) => response.data);
  }

  @override
  Future<bool> sendForfeit(String uid, String matchId) async {
    return _client
        .get(_baseUrl + 'forfeit?userId=' + uid + '&matchId=' + matchId)
        .catchError((e) => throw e)
        .then((response) => response.data);
  }

  @override
  Future<ActiveMatch> reconnect(
      String uid, String token, String matchId) async {
    return _client
        .get(_baseUrl +
            'reconnect?userId=' +
            uid +
            '&userFcmToken=' +
            token +
            '&matchId=' +
            matchId)
        .catchError((e) => throw e)
        .then((response) => ActiveMatch.fromMap(response.data));
  }
}
