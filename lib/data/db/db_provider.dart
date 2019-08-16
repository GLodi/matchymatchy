import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:squazzle/data/models/models.dart';

abstract class DbProvider {
  // Returns a GameField and TargetField with given id
  Future<Match> getMatch(int id);

  // Stores online match
  Future<void> storeMatchOnline(MatchOnline matchOnline);

  // Get online match
  Future<MatchOnline> getMatchOnline(String matchId);

  // Get all online matches
  Future<List<MatchOnline>> getAllMatchOnline();
}

class DbProviderImpl extends DbProvider {
  final String gameFieldTable = 'gamefields';
  final String matchOnlineTable = 'matchonline';

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await _initDatabase();
    return _db;
  }

  _initDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, 'asset_squazzle.db');
    var thedb = await openDatabase(databasePath);
    return thedb;
  }

  @override
  Future<Match> getMatch(int id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(gameFieldTable,
        columns: ['_id', 'grid', 'target'], where: '_id = ?', whereArgs: [id]);
    return maps.length > 0 ? Match.fromMap(maps.first) : null;
  }

  @override
  Future<void> storeMatchOnline(MatchOnline matchOnline) async =>
      await _db.insert(matchOnlineTable, matchOnline.toMap());

  @override
  Future<MatchOnline> getMatchOnline(String matchId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(matchOnlineTable, where: 'matchId = ?', whereArgs: [matchId]);
    return maps.length > 0 ? MatchOnline.fromMap(maps.first) : null;
  }

  @override
  Future<List<MatchOnline>> getAllMatchOnline() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(matchOnlineTable);
    List<MatchOnline> matches =
        maps.map((m) => MatchOnline.fromMap(m)).toList();
    return matches.length > 0 ? matches : null;
  }
}
