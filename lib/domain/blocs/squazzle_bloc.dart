import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/data.dart';

class SquazzleBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final SquazzleManager _manager;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  SquazzleBloc(this._manager) :
        super(initialState: SquazzleState.notInit());

  void setup() {
    _moveSubject.listen(_applyMove);
  }

  void _applyMove(List<int> list) {
    Move move = Move(from: list[0], dir: list[1]);
    _manager.applyMove(move).listen((field) {
      _gameFieldSubject.add(field);
    }).asFuture();
  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      SquazzleState result;
      await _manager.getGame().listen((field) {
        _gameFieldSubject.add(field);
        result = SquazzleState.init();
      } ).asFuture();
      yield result;
    }
  }
}