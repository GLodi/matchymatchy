import 'dart:math';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class SingleBloc extends GameBloc {
  final SingleManager manager;
  var ran = Random();
  GameField gameField;
  TargetField targetField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  SingleBloc(this.manager) : super(manager);

  @override
  Stream<SquazzleState> eventHandler(
      SquazzleEvent event, SquazzleState currentState) async* {
    switch (event.type) {
      case SquazzleEventType.start:
        SquazzleState result;
        int t = ran.nextInt(500) + 1;
        await manager
            .getGame(t)
            .handleError((e) =>
                result = SquazzleState.error('error retrieving data from db'))
            .listen((game) {
          gameField = game.gameField;
          targetField = game.targetField;
          result = SquazzleState.init();
        }).asFuture();
        yield result;
        break;
      case SquazzleEventType.victory:
        correctSubject.add(true);
        // TODO handle victory
        break;
      default:
    }
  }
}
