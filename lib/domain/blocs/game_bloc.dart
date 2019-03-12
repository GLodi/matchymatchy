import 'package:rxdart/rxdart.dart';

import 'dart:math';
import 'package:squazzle/domain/domain.dart';

abstract class GameBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final GameRepo gameRepo;
  final BehaviorSubject<bool> correctSubject = new BehaviorSubject<bool>();
  final BehaviorSubject<int> moveNumberSubject = new BehaviorSubject<int>();
  final int boh = Random().nextInt(1000);

  GameBloc(this.gameRepo) :
        super(initialState: SquazzleState.notInit());
}