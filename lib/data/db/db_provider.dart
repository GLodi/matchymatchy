import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:squazzle/data/models/models.dart';

abstract class DbProvider {
  Future<Match> getTestMatch(int id);

  Future<ActiveMatch> getActiveMatch(String matchId);

  Future<List<ActiveMatch>> getActiveMatches();

  Future<List<PastMatch>> getPastMatches();

  Future<void> storeActiveMatch(ActiveMatch activeMatch);

  Future<void> storeActiveMatches(List<ActiveMatch> list);

  Future<void> storePastMatches(List<PastMatch> list);

  Future<void> updateActiveMatch(ActiveMatch activeMatch);

  Future<void> deleteActiveMatch(String matchId);

  Future<void> deleteActiveMatches();

  Future<void> deletePastMatches();
}

class DbProviderImpl extends DbProvider {
  final String gameFieldTable = 'gamefields';
  final String activeMatchTable = 'activematches';
  final String pastMatchTable = 'pastmatches';

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
  Future<ActiveMatch> getActiveMatch(String matchId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(activeMatchTable, where: 'matchId = ?', whereArgs: [matchId]);
    return maps.length > 0 ? ActiveMatch.fromMap(maps.first) : null;
  }

  @override
  Future<void> storeActiveMatch(ActiveMatch activeMatch) async {
    var dbClient = await db;
    await dbClient.insert(activeMatchTable, activeMatch.toMap());
  }

  @override
  Future<List<ActiveMatch>> getActiveMatches() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(activeMatchTable);
    List<ActiveMatch> matches =
        maps.map((m) => ActiveMatch.fromMap(m)).toList();
    return matches.length > 0 ? matches : [];
  }

  @override
  Future<void> storeActiveMatches(List<ActiveMatch> list) async {
    var dbClient = await db;
    list.forEach((match) => dbClient.insert(activeMatchTable, match.toMap()));
    return null;
  }

  @override
  Future<List<PastMatch>> getPastMatches() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(pastMatchTable);
    List<PastMatch> matches = maps.map((m) => PastMatch.fromMap(m)).toList();
    return matches.length > 0 ? matches : [];
  }

  @override
  Future<void> storePastMatches(List<PastMatch> list) async {
    var dbClient = await db;
    list.forEach(
        (pastmatch) => dbClient.insert(pastMatchTable, pastmatch.toMap()));
    return null;
  }

  @override
  Future<void> updateActiveMatch(ActiveMatch activeMatch) async {
    var dbClient = await db;
    return await dbClient.update(activeMatchTable, activeMatch.toMap(),
        where: 'matchid = ?', whereArgs: [activeMatch.matchId]);
  }

  @override
  Future<void> deleteActiveMatch(String matchId) async {
    var dbClient = await db;
    return await dbClient
        .delete(activeMatchTable, where: 'matchid=?', whereArgs: [matchId]);
  }

  @override
  Future<void> deleteActiveMatches() async {
    var dbClient = await db;
    return await dbClient.delete(activeMatchTable);
  }

  @override
  Future<void> deletePastMatches() async {
    var dbClient = await db;
    return await dbClient.delete(pastMatchTable);
  }
}
