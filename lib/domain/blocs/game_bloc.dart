import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

abstract class GameBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final BehaviorSubject<bool> correctSubject;
  final BehaviorSubject<int> moveNumberSubject;

  GameBloc(this.correctSubject, this.moveNumberSubject) :
        super(initialState: SquazzleState.notInit());
}