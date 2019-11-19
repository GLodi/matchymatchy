import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/presentation.dart';

//import 'package:flutter/scheduler.dart' show timeDilation;

final bool isTest = false;

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  kiwi.Container container = kiwi.Container();

  //timeDilation = 10.0; // Will slow down animations by a factor of two

  // Providers
  container
      .registerSingleton<DbProvider, DbProviderImpl>((c) => DbProviderImpl());
  container.registerSingleton<ApiProvider, ApiProviderImpl>(
      (c) => ApiProviderImpl());
  container.registerSingleton<LogicProvider, LogicProviderImpl>(
      (c) => LogicProviderImpl());
  container.registerSingleton<LoginProvider, LoginProviderImpl>(
      (c) => LoginProviderImpl());
  container.registerSingleton<SharedPrefsProvider, SharedPrefsProviderImpl>(
      (c) => SharedPrefsProviderImpl(test: isTest));
  container.registerSingleton((c) => MessagingEventBus());

  // Repos
  container.registerFactory(
      (c) => SingleRepo(c.resolve<LogicProvider>(), c.resolve<DbProvider>()));
  container.registerFactory((c) => MultiRepo(
      c.resolve<ApiProvider>(),
      c.resolve<MessagingEventBus>(),
      c.resolve<SharedPrefsProvider>(),
      c.resolve<LogicProvider>(),
      c.resolve<DbProvider>()));
  container.registerFactory((c) => HomeRepo(
      c.resolve<LoginProvider>(),
      c.resolve<SharedPrefsProvider>(),
      c.resolve<ApiProvider>(),
      c.resolve<DbProvider>()));
  container.registerFactory((c) => HomeMatchListRepo(
        c.resolve<DbProvider>(),
        c.resolve<SharedPrefsProvider>(),
        c.resolve<ApiProvider>(),
      ));
  container.registerFactory((c) => WinRepo(c.resolve<MessagingEventBus>()));

  // Blocs
  container.registerFactory((c) => SingleBloc(c.resolve<SingleRepo>()));
  container.registerFactory(
      (c) => MultiBloc(c.resolve<MultiRepo>(), c.resolve<MessagingEventBus>()));
  container.registerFactory(
      (c) => HomeBloc(c.resolve<HomeRepo>(), c.resolve<MessagingEventBus>()));
  container.registerFactory((c) => HomeMatchListBloc(
      c.resolve<HomeMatchListRepo>(), c.resolve<MessagingEventBus>()));
  container.registerFactory((c) => WinBloc(c.resolve<WinRepo>()));

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => BlocProvider(
              child: HomeScreen(isTest: isTest),
              bloc: kiwi.Container().resolve<HomeBloc>(),
            ),
      },
    );
  }
}
