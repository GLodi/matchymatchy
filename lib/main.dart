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

  // Providers (Model)
  container.registerSingleton<DbProvider, DbProviderImpl>(
      (c) => new DbProviderImpl());
  container.registerSingleton<ApiProvider, ApiProviderImpl>(
      (c) => new ApiProviderImpl());
  container.registerSingleton<LogicProvider, LogicProviderImpl>(
      (c) => new LogicProviderImpl());
  container.registerSingleton<LoginProvider, LoginProviderImpl>(
      (c) => new LoginProviderImpl());
  container.registerSingleton<SharedPrefsProvider, SharedPrefsProviderImpl>(
      (c) => new SharedPrefsProviderImpl());

  // Repos (Controller)
  container.registerSingleton((c) =>
      new SingleRepo(c.resolve<LogicProvider>(), c.resolve<DbProvider>()));
  container.registerSingleton((c) => new MultiRepo(c.resolve<LogicProvider>(),
      c.resolve<ApiProvider>(), c.resolve<SharedPrefsProvider>()));
  container.registerSingleton((c) => new HomeRepo(
      c.resolve<LoginProvider>(), c.resolve<SharedPrefsProvider>()));

  // Blocs (Controller, every View(Widget) has its own Bloc)
  container.registerFactory((c) => new SingleBloc(c.resolve<SingleRepo>()));
  container.registerFactory((c) => new MultiBloc(c.resolve<MultiRepo>()));
  container.registerFactory((c) => new HomeBloc(c.resolve<HomeRepo>()));

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
