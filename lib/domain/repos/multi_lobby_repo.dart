import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';

abstract class MultiLobbyRepo {

  Observable<void> queuePlayer();

}


class MultiLobbyRepoImpl implements MultiLobbyRepo {
  final ApiProvider _apiProvider;

  MultiLobbyRepoImpl(this._apiProvider);

  @override
  Observable<void> queuePlayer() => 
    Observable.fromFuture(_apiProvider.queuePlayer()).handleError((e) => throw e);

}