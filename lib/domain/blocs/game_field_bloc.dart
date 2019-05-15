import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'game_bloc.dart';

/// GameFieldWidget's bloc.
class GameFieldBloc extends BlocEventStateBase<WidgetEvent, WidgetState> {
  final GameBloc gameBloc;

  final _gameFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get gameField => _gameFieldSubject.stream;

  final _moveSubject = PublishSubject<List<int>>();
  Sink<List<int>> get move => _moveSubject.sink;

  GameFieldBloc(this.gameBloc);

  void setup() {
    _moveSubject.listen(_applyMove);
  }

  void _applyMove(List<int> list) async {
    Move move = Move(from: list[0], dir: list[1]);
    GameField field =
        await gameBloc.gameRepo.applyMove(gameBloc.gameField, move);
    gameBloc.gameField = field;
    _gameFieldSubject.add(field);
    int moves = await gameBloc.gameRepo.getMoves();
    gameBloc.moveNumberSubject.add(moves);
    bool isCorrect = await gameBloc.gameRepo
        .isCorrect(gameBloc.gameField, gameBloc.targetField);
    if (isCorrect) gameBloc.emitEvent(GameEvent(type: GameEventType.victory));
  }

  @override
  Stream<WidgetState> eventHandler(
      WidgetEvent event, WidgetState currentState) async* {
    if (event.type == WidgetEventType.start) {
      _gameFieldSubject.add(gameBloc.gameField);
    }
  }

  @override
  void dispose() {
    _gameFieldSubject.close();
    _moveSubject.close();
    super.dispose();
  }
}
