import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/data.dart';

class SingleBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final SingleRepo _repo;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;
  final _targetFieldSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get targetField => _targetFieldSubject.stream;
  final correctSubject = BehaviorSubject<bool>();
  Stream<bool> get correct => correctSubject.stream;
  final moveNumberSubject = BehaviorSubject<int>();
  Stream<int> get moveNumber => moveNumberSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  SingleBloc(this._repo) : super(initialState: SquazzleState.notInit());

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {

      await _repo.getTarget().listen((target) {
        _targetFieldSubject.add(target);
      }).asFuture();
      yield SquazzleState.init();
    }
  }

  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    _gameFieldSubject.close();
    _targetFieldSubject.close();
    _moveSubject.close();
    super.dispose();
  }
}