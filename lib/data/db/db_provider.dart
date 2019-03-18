import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:squazzle/data/models/models.dart';

abstract class DbProvider {

  // Returns a GameField and TargetField with given id.
  Future<Game> getGame(int id);

  /// Returns amount of moves played on specified game.
  Future<int> getMovesNumber(int id);

}

class DbProviderImpl extends DbProvider {
  static Database _db;

  Future<Database> get db async {
      if(_db != null)
        return _db;
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
  Future<Game> getGame(int id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query('gamefields',
        columns: ['_id', 'grid', 'target'],
        where: '_id = ?',
        whereArgs: [id]);
    return maps.length > 0 ? Game.fromMap(maps.first) : null;
  }

  @override
  Future<int> getMovesNumber(int id) async {
    // TODO: implement getMovesNumber
    return null;
  }
}