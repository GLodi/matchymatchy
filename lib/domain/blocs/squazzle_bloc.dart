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
  final _moveNumberSubject = BehaviorSubject<int>();
  Stream<int> get moveNumber => _moveNumberSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  SquazzleBloc(this._manager) :
        super(initialState: SquazzleState.notInit());

  void setup() {
    _moveSubject.listen(_applyMove);
  }

  void _applyMove(List<int> list) async {
    Move move = Move(from: list[0], dir: list[1]);
    await _manager.applyMove(move).listen((field) {
      _gameFieldSubject.add(field);
      _manager.checkIfCorrect().listen((correct) {if (correct) _correctSubject.add(correct);});
    }).asFuture();
    await _manager.getMovesAmount().listen((amount) {
      _moveNumberSubject.add(amount);
    }).asFuture();
  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      await _manager.getDb().listen((field) {
        _gameFieldSubject.add(field);
      }).asFuture();
      await _manager.getTarget().listen((target) {
        _targetFieldSubject.add(target);
      }).asFuture();
      yield SquazzleState.init();
    }
  }

  @override
  void dispose() {
    _correctSubject.close();
    _moveNumberSubject.close();
    _gameFieldSubject.close();
    _targetFieldSubject.close();
    super.dispose();
  }
}