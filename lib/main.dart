import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/presentation.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  kiwi.Container container = new kiwi.Container();
  container.registerSingleton((c) =>
    new NetUtils());
  container.registerSingleton<ApiProvider, ApiProviderImpl>((c) =>
    new ApiProviderImpl(c.resolve<NetUtils>()));
  container.registerSingleton<LogicProvider, LogicProviderImpl>((c) =>
    new LogicProviderImpl());
  container.registerSingleton((c) =>
    new SingleRepo(c.resolve<LogicProvider>()));
  container.registerSingleton((c) =>
    new MultiRepo(c.resolve<ApiProvider>()));
  container.registerSingleton((c) =>
    new SingleBloc(c.resolve<SingleRepo>()));
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