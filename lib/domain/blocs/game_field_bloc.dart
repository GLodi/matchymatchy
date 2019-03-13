import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'game_bloc.dart';

class GameFieldBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final GameBloc _gameBloc;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  GameFieldBloc(this._gameBloc);

  void setup() {
    _moveSubject.listen(_applyMove);
  }

  void _applyMove(List<int> list) async {
    Move move = Move(from: list[0], dir: list[1]);
    await _gameBloc.gameRepo.applyMove(move).listen((field) {
      _gameFieldSubject.add(field);
      _gameBloc.gameRepo.checkIfCorrect().listen((correct) {
        if (correct) _gameBloc.correctSubject.add(correct);});
    }).asFuture();
    await _gameBloc.gameRepo.getMovesAmount().listen((amount) {
      _gameBloc.moveNumberSubject.add(amount);
    }).asFuture();
  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      await _gameBloc.gameRepo.getGameField().listen((field) {
        _gameFieldSubject.add(field);
      }).asFuture();
    }
  }

  @override
  void dispose() {
    _gameFieldSubject.close();
    _moveSubject.close();
    super.dispose();
  }

}