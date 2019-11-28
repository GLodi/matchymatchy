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
  StreamSubscription _moveSubs;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  final _enemyMoveSubject = BehaviorSubject<int>();
  Stream<int> get enemyMove => _enemyMoveSubject.stream;

  final _onItemPressSubject = PublishSubject<bool>();
  Sink<bool> get onItemPress => _onItemPressSubject.sink;

  ActiveMatchItemBloc(this._repo, this._messEventBus)
      : super(initialState: ActiveItemState.notInit());

  void setup() async {
    _onItemPressSubject.listen((_) async {
      print('onitempress');
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
    if (_moveSubs == null) {
      _moveSubs = _messEventBus.on<MoveMessage>().listen((mess) async {
        if (matchId == mess.matchId) {
          _enemyMoveSubject.add(mess.enemyMoves);
          await _repo.updateActiveMatchMove(mess.enemyMoves, mess.matchId);
        }
      });
    }
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    _enemyMoveSubject.close();
    _moveSubs.cancel();
    super.dispose();
  }
}
