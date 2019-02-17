import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/home_screen.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  kiwi.Container container = new kiwi.Container();
  container.registerSingleton((c) =>
    new NetUtils());
  container.registerSingleton((c) =>
    new ApiHelper(c.resolve<NetUtils>()));
  container.registerSingleton((c) =>
    new SquazzleManager(c.resolve<ApiHelper>()));
  container.registerSingleton((c) =>
    new SquazzleBloc(c.resolve<SquazzleManager>()));
  runApp(App());
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
          bloc: kiwi.Container().resolve<SquazzleBloc>(),
        ),
      ),
    );
  }
}