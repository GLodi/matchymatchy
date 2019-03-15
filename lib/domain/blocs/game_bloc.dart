import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

abstract class GameBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final GameRepo gameRepo;
  final BehaviorSubject<bool> correctSubject = new BehaviorSubject<bool>();
  final BehaviorSubject<int> moveNumberSubject = new BehaviorSubject<int>();
  GameField get gameField;
  set gameField(GameField gameField);
  TargetField get targetField;
  set targetField(TargetField targetField);

  GameBloc(this.gameRepo) :
        super(initialState: SquazzleState.notInit());
}