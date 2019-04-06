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
              .doOnData((update) {
            print(update);
            _matchUpdateSubject.add(update);
          });
          await repo
              .queuePlayer(uid)
              .handleError(
                  (e) => result = GameState.error('error queueing to server'))
              .listen((game) {
            gameField = game.gameField;
            targetField = game.targetField;
            enemyField = game.targetField;
            result = GameState.init();
          }).asFuture();
        }
        yield result;
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
