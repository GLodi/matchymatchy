import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiBloc extends GameBloc {
  final MultiRepo repo;
  GameField _gameField;
  TargetField _targetField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  @override GameField get gameField => _gameField;
  @override set gameField(GameField gameField) => _gameField = gameField;  
  @override TargetField get targetField => _targetField;
  @override set targetField(TargetField targetField) => _targetField = targetField;

  MultiBloc(this.repo) : super(repo);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
    }
    if (event.type == SquazzleEventType.error) {
      yield SquazzleState(type: SquazzleStateType.error, message: "Error fetching data.");
    }
  }
  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}