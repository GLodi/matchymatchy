import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

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

  runApp(App());
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