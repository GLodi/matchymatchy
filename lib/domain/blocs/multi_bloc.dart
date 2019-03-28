import 'dart:math';
import 'package:uuid/uuid.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiBloc extends GameBloc {
  final MultiRepo repo;
  final ran = Random();
  final uuid = Uuid();
  GameField gameField;
  TargetField targetField;
  EnemyField enemyField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  MultiBloc(this.repo) : super(repo);

  @override
  Stream<SquazzleState> eventHandler(
      SquazzleEvent event, SquazzleState currentState) async* {
    switch (event.type) {
      case SquazzleEventType.start:
        SquazzleState result;
        int t = ran.nextInt(1000) + 1;
        await repo
            .queuePlayer(t, uuid.v1())
            .handleError((e) => result =
                SquazzleState.error('error queueing data from server'))
            .listen((_) {})
            .asFuture();
        await repo
            .getGame(t)
            .handleError((e) => result =
                SquazzleState.error('error retrieving data from server'))
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
