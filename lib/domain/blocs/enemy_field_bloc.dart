import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'game_bloc.dart';

class EnemyFieldBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState>  {
  final GameBloc _gameBloc;

  final _enemyFieldSubject = BehaviorSubject<GameField>();
  Stream<GameField> get enemyField => _enemyFieldSubject.stream;
  
  EnemyFieldBloc(this._gameBloc);

  

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) {
    // TODO: implement eventHandler
    return null;
  }

  @override
  void dispose() {
    _enemyFieldSubject.close();
    super.dispose();
  }

}