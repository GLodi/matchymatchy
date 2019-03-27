import 'dart:math';
import 'package:uuid/uuid.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiBloc extends GameBloc {
  final MultiManager manager;
  final ran = Random();
  final uuid = Uuid();
  GameField gameField;
  TargetField targetField;
  EnemyField enemyField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  MultiBloc(this.manager) : super(manager);

  @override
  Stream<SquazzleState> eventHandler(
      SquazzleEvent event, SquazzleState currentState) async* {
    switch (event.type) {
      case SquazzleEventType.start:
        SquazzleState result;
        String uid;
        await manager
            .getStoredUid()
            .handleError((e) => result =
                SquazzleState.error('error retrieving uid from shared prefs'))
            .listen((uidd) => uid = uidd)
            .asFuture();
        if (uid != null) {
          await manager
              .queuePlayer(uid)
              .handleError(
                  (e) => result = SquazzleState.error('error queueing'))
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
