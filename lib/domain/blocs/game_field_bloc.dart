import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'game_bloc.dart';

/// GameFieldWidget's bloc.
/// It stores current amount of moves used and reacts to player's swipes.
class GameFieldBloc extends BlocEventStateBase<WidgetEvent, WidgetState> {
  final GameBloc _gameBloc;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  GameFieldBloc(this._gameBloc);

  void setup() {
    _moveSubject.listen(_applyMove);
    _gameBloc.moves = 0;
  }

  void _applyMove(List<int> list) async {
    Move move = Move(from: list[0], dir: list[1]);
    await _gameBloc.gameRepo
        .applyMove(_gameBloc.gameField, move)
        .handleError(
            (e) => _gameBloc.emitEvent(GameEvent(type: GameEventType.error)))
        .listen((field) {
      _gameBloc.gameField = field;
      _gameFieldSubject.add(field);
      _gameBloc.moves += 1;
      _gameBloc.moveNumberSubject.add(_gameBloc.moves);
      _gameBloc.gameRepo
          .checkIfCorrect(_gameBloc.gameField, _gameBloc.targetField)
          .listen((correct) {
        if (correct) {
          _gameBloc.emitEvent(GameEvent(type: GameEventType.victory));
        }
      });
    }).asFuture();
  }

  @override
  Stream<WidgetState> eventHandler(
      WidgetEvent event, WidgetState currentState) async* {
    if (event.type == WidgetEventType.start) {
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
