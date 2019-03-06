import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'game_bloc.dart';

class GameFieldBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final GameRepo _repo;
  final GameBloc _bloc;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  GameFieldBloc(this._repo, this._bloc);

  void setup() {
    _moveSubject.listen(_applyMove);
  }

  void _applyMove(List<int> list) async {
    Move move = Move(from: list[0], dir: list[1]);
    await _repo.applyMove(move).listen((field) {
      _gameFieldSubject.add(field);
      _repo.checkIfCorrect().listen((correct) {if (correct) _bloc.correctSubject.add(correct);});
    }).asFuture();
    await _repo.getMovesAmount().listen((amount) {
      _bloc.moveNumberSubject.add(amount);
    }).asFuture();
  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      await _repo.getGame().listen((field) {
        _gameFieldSubject.add(field);
      }).asFuture();
    }
  }

}