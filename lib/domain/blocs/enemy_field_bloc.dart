import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

/// EnemyFieldWidget's bloc. 
/// As this Widget is used only in Multiplayer, it depends
/// on MultiBloc's notification stream (matchUpdates) to 
/// update the enemy field when necessary.
class EnemyFieldBloc extends BlocEventStateBase<WidgetEvent, WidgetState> {
  final MultiBloc _multiBloc;

  final _enemyFieldSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get enemyField => _enemyFieldSubject.stream;

  EnemyFieldBloc(this._multiBloc);

  @override
  Stream<WidgetState> eventHandler(
      WidgetEvent event, WidgetState currentState) async* {
    if (event.type == WidgetEventType.start) {
      _multiBloc.matchUpdates.listen((update) { 
      _enemyFieldSubject.add(update);
      });
    }
  }

  @override
  void dispose() {
    _enemyFieldSubject.close();
    super.dispose();
  }
}
