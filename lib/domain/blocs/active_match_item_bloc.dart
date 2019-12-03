import 'package:rxdart/rxdart.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class ActiveMatchItemBloc
    extends BlocEventStateBase<ActiveItemEvent, ActiveItemState> {
  final ActiveMatchItemRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _enemyMoveSubs, _playerMoveSubs;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  final _enemyMovesSubject = BehaviorSubject<int>();
  Stream<int> get enemyMoves => _enemyMovesSubject.stream;

  final _playerMovesSubject = BehaviorSubject<int>();
  Stream<int> get playerMoves => _playerMovesSubject.stream;

  final _onItemPressSubject = PublishSubject<bool>();
  Sink<bool> get onItemPress => _onItemPressSubject.sink;

  ActiveMatchItemBloc(this._repo, this._messEventBus)
      : super(initialState: ActiveItemState.notInit());

  void setup() async {
    _onItemPressSubject.listen((_) async {
      ConnectivityResult result =
          await Connectivity().checkConnectivity().then((r) => r);
      if (result != ConnectivityResult.none)
        _intentToMultiScreenSubject.add(null);
    });
  }

  @override
  Stream<ActiveItemState> eventHandler(
      ActiveItemEvent event, ActiveItemState currentState) async* {
    switch (event.type) {
      case ActiveItemEventType.start:
        listenToMessages(event.matchId);
        break;
      default:
    }
  }

  void listenToMessages(String matchId) async {
    if (_enemyMoveSubs == null && _playerMoveSubs == null) {
      _enemyMoveSubs =
          _messEventBus.on<EnemyMoveMessage>().listen((mess) async {
        if (matchId == mess.matchId) {
          _enemyMovesSubject.add(mess.enemyMoves);
          await _repo.updateActiveMatchOnEnemyMove(
              mess.enemyMoves, mess.matchId);
        }
      });
      _playerMoveSubs = _messEventBus.on<PlayerMessage>().listen((mess) async {
        int moves = await _repo.getActiveMatchPlayerMove(mess.matchId);
        _playerMovesSubject.add(moves);
      });
    }
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    _enemyMovesSubject.close();
    _playerMovesSubject.close();
    // TODO: this is called on null
    _enemyMoveSubs.cancel();
    _playerMoveSubs.cancel();
    super.dispose();
  }
}
