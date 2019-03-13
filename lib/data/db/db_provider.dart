import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:squazzle/data/models/models.dart';

abstract class DbProvider {

  /// Returns a Game with a random GameField and TargetField.
  Future<Game> getRandomGame();

  /// Returns GameField with given id.
  Future<GameField> getGameField(int id);

  /// Returns TargetField with given id.
  Future<TargetField> getTarget(int id);

  /// Returns amount of moves played on specified game.
  Future<int> getMovesNumber(int id);

}

class DbProviderImpl extends DbProvider {
  final _databaseName = "squazzle.db";
  final _databaseVersion = 1;
  Database _db;

  DbProviderImpl() { init(); }

  init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE gamefield (
            _id INTEGER PRIMARY KEY,
             TEXT NOT NULL,
            $columnAge INTEGER NOT NULL
          )
          ''');
  }

  @override
  Future<Game> getRandomGame() {
    // TODO: implement getRandomGame
    return null;
  }

  @override
  Future<GameField> getGameField(int id) {
    // TODO: implement getGameField
    return null;
  }

  @override
  Future<TargetField> getTarget(int id) {
    // TODO: implement getTarget
    return null;
  }

  @override
  Future<int> getMovesNumber(int id) {
    // TODO: implement getMovesNumber
    return null;
  }
}