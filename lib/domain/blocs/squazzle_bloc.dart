import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/data.dart';

class SquazzleBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final SquazzleManager _manager;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;
  final _targetFieldSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get targetField => _targetFieldSubject.stream;
  final _correctSubject = BehaviorSubject<bool>();
  Stream<bool> get correct => _correctSubject.stream;

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
      _manager.checkIfCorrect().listen((correct) {
        if (correct) _correctSubject.add(correct);
      }
      );
    }).asFuture();
  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      await _manager.getGame().listen((field) {
        _gameFieldSubject.add(field);
      }).asFuture();
      await _manager.getTarget().listen((target) {
        _targetFieldSubject.add(target);
      }).asFuture();
      yield SquazzleState.init();
    }
  }
}