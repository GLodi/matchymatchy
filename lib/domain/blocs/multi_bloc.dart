import 'dart:math';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiBloc extends GameBloc {
  final MultiRepo repo;
  final ran = Random();
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
        String uid;
        await repo
            .getStoredUid()
            .handleError((e) => result =
                SquazzleState.error('error retrieving uid from shared prefs'))
            .listen((uuid) => uid = uuid)
            .asFuture();
        if (uid != null) {
          await repo
              .queuePlayer(uid)
              .handleError((e) =>
                  result = SquazzleState.error('error queueing to server'))
              .listen((_) {})
              .asFuture();
        }
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
