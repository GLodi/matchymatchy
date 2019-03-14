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
  Database db;
  bool initialized = false;

  _initDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, 'asset_squazzle.db');
    this.db = await openDatabase(databasePath);
    initialized = true;
  }

  @override
  Future<Game> getRandomGame() async {
    if (!initialized) _initDatabase();
    // TODO: implement getRandomGame
    return null;
  }

  @override
  Future<GameField> getGameField(int id) async {
    if (!initialized) _initDatabase();
    // TODO: implement getGameField
    return null;
  }

  @override
  Future<TargetField> getTarget(int id) async {
    if (!initialized) _initDatabase();
    // TODO: implement getTarget
    return null;
  }

  @override
  Future<int> getMovesNumber(int id) async {
    if (!initialized) _initDatabase();
    // TODO: implement getMovesNumber
    return null;
  }
}