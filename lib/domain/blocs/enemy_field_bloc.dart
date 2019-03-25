import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

class EnemyFieldBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState>  {
  final MultiBloc _multiBloc;

  final _enemyFieldSubject = BehaviorSubject<EnemyField>();
  Stream<EnemyField> get enemyField => _enemyFieldSubject.stream;
  
  EnemyFieldBloc(this._multiBloc);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      _enemyFieldSubject.add(_multiBloc.enemyField);
    }
  }

  @override
  void dispose() {
    _enemyFieldSubject.close();
    super.dispose();
  }

}