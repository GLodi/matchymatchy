import 'dart:math';
import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiBloc extends GameBloc {
  final MultiRepo repo;
  final ran = Random();
  GameField gameField;
  TargetField targetField;
  TargetField enemyField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  final _matchUpdateSubject = BehaviorSubject<MatchUpdate>();
  Stream<MatchUpdate> get matchUpdate => _matchUpdateSubject.stream;

  MultiBloc(this.repo) : super(repo);

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    switch (event.type) {
      case GameEventType.start:
        GameState result;
        String uid;
        await repo
            .getStoredUid()
            .handleError((e) => result =
                GameState.error('error retrieving uid from shared prefs'))
            .listen((uuid) => uid = uuid)
            .asFuture();
        if (uid != null) {
          repo
              .listenToMatchUpdates()
              .handleError((e) => print(e))
              .doOnData((update) => _matchUpdateSubject.add(update));
          // TODO should store first field and target, then show "waiting for players"
          await repo
              .queuePlayer(uid)
              .handleError((e) =>
                  result = GameState.error('error queueing to server'))
              .listen((boolean) {
            if (boolean) result = GameState.init();
          }).asFuture();
        }
        yield result;
        gameField = GameField(grid: "1111111111111111111111111");
        targetField = TargetField(grid: "222222222");
        enemyField = TargetField(grid: "111111111");
        yield GameState.init();
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        // TODO handle victory
        break;
      default:
    }
  }

  @override
  void dispose() {
    _matchUpdateSubject.close();
    super.dispose();
  }
}
