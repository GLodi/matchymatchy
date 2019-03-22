import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'game_bloc.dart';

class GameFieldBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final GameBloc _gameBloc;
  int moveAmount = 0;

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
    await _gameBloc.gameRepo.applyMove(_gameBloc.gameField, move)
    .listen((field) {
      _gameBloc.gameField = field;
      _gameFieldSubject.add(field);
      moveAmount += 1;
      _gameBloc.moveNumberSubject.add(moveAmount);
      _gameBloc.gameRepo.checkIfCorrect(_gameBloc.gameField, _gameBloc.targetField).listen((correct) {
        if (correct) {
          _gameBloc.emitEvent(SquazzleEvent(type: SquazzleEventType.victory));
        }
      });
    }, onError: (e) => 
      _gameBloc.emitEvent(SquazzleEvent(type: SquazzleEventType.error))
    ).asFuture();
  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {        
      _gameFieldSubject.add(_gameBloc.gameField);
    }
  }

  @override
  void dispose() {
    _gameFieldSubject.close();
    _moveSubject.close();
    super.dispose();
  }

}