import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/presentation.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  kiwi.Container container = new kiwi.Container();

  // Providers
  container.registerSingleton<DbProvider, DbProviderImpl>((c) =>
    new DbProviderImpl());
  container.registerSingleton<ApiProvider, ApiProviderImpl>((c) =>
    new ApiProviderImpl());
  container.registerSingleton<LogicProvider, LogicProviderImpl>((c) =>
    new LogicProviderImpl());

  // Repos
  container.registerSingleton((c) =>
    new SingleRepo(c.resolve<LogicProvider>(), c.resolve<DbProvider>()));
  container.registerSingleton((c) =>
    new MultiRepo(c.resolve<ApiProvider>()));

  // Blocs
  container.registerFactory((c) =>
    new SingleBloc(c.resolve<SingleRepo>()));
  container.registerFactory((c) =>
    new MultiBloc(c.resolve<MultiRepo>()));

  initDb();

  //initRemoteDb();

  runApp(App());
}

void initDb() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, "asset_squazzle.db");

  // Only copy if the database doesn't exist
  if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
    // Load database from asset and copy
    ByteData data = await rootBundle.load(join('assets', 'squazzle.db'));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await new File(path).writeAsBytes(bytes);
  }
}

void initRemoteDb() async {
    // Construct a file path to copy database to
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, "asset_squazzle_fire.db");

  // Only copy if the database doesn't exist
  if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
    // Load database from asset and copy
    ByteData data = await rootBundle.load(join('assets', 'squazzlefire.db'));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await new File(path).writeAsBytes(bytes);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, 'asset_squazzle_fire.db');
    var thedb = await openDatabase(databasePath);

    for(int id = 1; id<1001; id++) {
      var dbClient = await thedb;
      List<Map> maps = await dbClient.query('gamefields',
          columns: ['_id', 'grid', 'target'],
          where: '_id = ?',
          whereArgs: [id]);
      var a = GameField.fromMap(maps.first);
      Firestore.instance.runTransaction((transactionHandler) async {
        await transactionHandler.set(Firestore.instance.collection('gamefields').document(id.toString()), {
              'grid': a.grid,
              'target' : a.target,
          },
        );
      });
    }

  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}