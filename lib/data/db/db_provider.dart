import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:squazzle/data/models/models.dart';

abstract class DbProvider {
  Future<Match> getTestMatch(int id);

  Future<MatchOnline> getActiveMatch(String matchId);

  // TODO: check that if match already exists, don't do anything
  Future<void> storeActiveMatch(MatchOnline matchOnline);

  Future<List<MatchOnline>> getActiveMatches();

  Future<void> storeActiveMatches(List<MatchOnline> list);

  Future<List<PastMatch>> getPastMatches();

  Future<void> storePastMatches(List<PastMatch> list);
}

class DbProviderImpl extends DbProvider {
  final String gameFieldTable = 'gamefields';
  final String matchOnlineTable = 'matchonline';

  static Database _db;

  DbProviderImpl() {
    _initDatabase();
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    await _initDatabase();
    return _db;
  }

  _initDatabase() async {
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, "app.db");
    await deleteDatabase(dbPath);
    ByteData data = await rootBundle.load("assets/squazzle.db");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);
    _db = await openDatabase(dbPath);
  }

  @override
  Future<Match> getTestMatch(int id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(gameFieldTable,
        columns: ['_id', 'grid', 'target'], where: '_id = ?', whereArgs: [id]);
    return maps.length > 0 ? Match.fromMap(maps.first) : null;
  }

  @override
  Future<MatchOnline> getActiveMatch(String matchId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(matchOnlineTable, where: 'matchId = ?', whereArgs: [matchId]);
    return maps.length > 0 ? MatchOnline.fromMap(maps.first) : null;
  }

  @override
  Future<void> storeActiveMatch(MatchOnline matchOnline) async {
    var dbClient = await db;
    await dbClient.insert(matchOnlineTable, matchOnline.toMap());
  }

  @override
  Future<List<MatchOnline>> getActiveMatches() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(matchOnlineTable);
    List<MatchOnline> matches =
        maps.map((m) => MatchOnline.fromMap(m)).toList();
    return matches.length > 0 ? matches : null;
  }

  @override
  Future<void> storeActiveMatches(List<MatchOnline> list) async {
    var dbClient = await db;
    list.forEach((match) => dbClient.insert(matchOnlineTable, match.toMap()));
    return null;
  }

  @override
  Future<List<PastMatch>> getPastMatches() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(matchOnlineTable);
    List<PastMatch> matches = maps.map((m) => PastMatch.fromMap(m)).toList();
    return matches.length > 0 ? matches : null;
  }

  @override
  Future<void> storePastMatches(List<PastMatch> list) async {
    var dbClient = await db;
    list.forEach(
        (pastmatch) => dbClient.insert(matchOnlineTable, pastmatch.toMap()));
    return null;
  }
}
