import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/data/data.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/presentation.dart';

final bool isTest = false;

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  kiwi.Container container = kiwi.Container();

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
  container.registerSingleton(
      (c) => SingleRepo(c.resolve<LogicProvider>(), c.resolve<DbProvider>()));
  container.registerSingleton((c) => MultiRepo(
      c.resolve<ApiProvider>(),
      c.resolve<MessagingEventBus>(),
      c.resolve<SharedPrefsProvider>(),
      c.resolve<LogicProvider>(),
      c.resolve<DbProvider>()));
  container.registerSingleton((c) => HomeRepo(
      c.resolve<LoginProvider>(),
      c.resolve<SharedPrefsProvider>(),
      c.resolve<DbProvider>(),
      c.resolve<ApiProvider>()));
  container.registerSingleton((c) => HomePageViewListRepo(
        c.resolve<DbProvider>(),
      ));

  // Blocs
  container.registerFactory((c) => SingleBloc(c.resolve<SingleRepo>()));
  container.registerFactory(
      (c) => MultiBloc(c.resolve<MultiRepo>(), c.resolve<MessagingEventBus>()));
  container.registerFactory(
      (c) => HomeBloc(c.resolve<HomeRepo>(), c.resolve<MessagingEventBus>()));
  container.registerFactory(
      (c) => HomePageViewListBloc(c.resolve<HomePageViewListRepo>()));

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
              child: HomeScreen(isTest),
              bloc: kiwi.Container().resolve<HomeBloc>(),
            ),
        '/single': (context) => BlocProvider(
              child: SingleScreen(),
              bloc: kiwi.Container().resolve<SingleBloc>(),
            ),
        '/multi': (context) => BlocProvider(
              child: MultiScreen(),
              bloc: kiwi.Container().resolve<MultiBloc>(),
            ),
      },
    );
  }
}
