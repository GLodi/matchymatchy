import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/presentation.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  kiwi.Container container = new kiwi.Container();

  // Providers
  container.registerSingleton<DbRepo, DbRepoImpl>((c) => new DbRepoImpl());
  container.registerSingleton<ApiRepo, ApiRepoImpl>((c) => new ApiRepoImpl());
  container
      .registerSingleton<LogicRepo, LogicRepoImpl>((c) => new LogicRepoImpl());
  container
      .registerSingleton<LoginRepo, LoginRepoImpl>((c) => new LoginRepoImpl());
  container.registerSingleton<SharedPrefsRepo, SharedPrefsRepoImpl>(
      (c) => new SharedPrefsRepoImpl());

  // Repos
  container.registerSingleton(
      (c) => new SingleManager(c.resolve<LogicRepo>(), c.resolve<DbRepo>()));
  container.registerSingleton((c) => new MultiManager(c.resolve<LogicRepo>(),
      c.resolve<ApiRepo>(), c.resolve<SharedPrefsRepo>()));
  container.registerSingleton((c) =>
      new HomeManager(c.resolve<LoginRepo>(), c.resolve<SharedPrefsRepo>()));

  // Blocs
  container.registerFactory((c) => new SingleBloc(c.resolve<SingleManager>()));
  container.registerFactory((c) => new MultiBloc(c.resolve<MultiManager>()));
  container.registerFactory((c) => new HomeBloc(c.resolve<HomeManager>()));

  initDb();

  runApp(App());
}

void initDb() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, "asset_squazzle.db");

  // Only copy if the database doesn't exist
  if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
    // Load database from asset and copy
    ByteData data = await rootBundle.load(join('assets', 'squazzle.db'));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await new File(path).writeAsBytes(bytes);
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: BlocProvider(
          child: HomeScreen(),
          bloc: kiwi.Container().resolve<HomeBloc>(),
        ),
      ),
    );
  }
}
