import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// TargetFieldWidget's bloc.
/// Stores first (and only) TargetField to show, although
/// it is setup to react to new ones.
class TargetBloc extends BlocEventStateBase<WidgetEvent, WidgetState> {
  final GameBloc _gameBloc;

  final _targetFieldSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get targetField => _targetFieldSubject.stream;

  TargetBloc(this._gameBloc);

  @override
  Stream<WidgetState> eventHandler(
      WidgetEvent event, WidgetState currentState) async* {
    if (event.type == WidgetEventType.start) {
      _targetFieldSubject.add(_gameBloc.targetField);
    }
  }

  @override
  void dispose() {
    _targetFieldSubject.close();
    super.dispose();
  }
}
