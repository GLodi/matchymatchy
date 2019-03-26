import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class TargetBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final GameBloc _gameBloc;

  final _targetFieldSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get targetField => _targetFieldSubject.stream;

  TargetBloc(this._gameBloc);

  @override
  Stream<SquazzleState> eventHandler(
      SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      _targetFieldSubject.add(_gameBloc.targetField);
    }
  }

  @override
  void dispose() {
    _targetFieldSubject.close();
    super.dispose();
  }
}
