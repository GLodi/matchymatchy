import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// In addition to the functionalities available through Gamebloc,
/// the Multiplayer version of the game needs an Enemy
class MultiBloc extends GameBloc {
  final MultiRepo repo;
  StreamSubscription moveSub, challengeSub, winnerSub;

  // Streams extracted from GameBloc's subjects
  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  // Shows waiting for players message after connecting to server
  final _waitMessageSubject = BehaviorSubject<String>();
  Stream<String> get waitMessage => _waitMessageSubject.stream;

  // Updates enemy target
  final _enemyTargetSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get enemyTarget => _enemyTargetSubject.stream;

  // Updates enemy target
  final _hasMatchStartedSubject = BehaviorSubject<bool>();
  Stream<bool> get hasMatchStarted => _hasMatchStartedSubject.stream;

  // Updates enemy name on appbar
  final _enemyNameSubject = BehaviorSubject<String>();
  Stream<String> get enemyName => _enemyNameSubject.stream;

  // Listen to forfeit button press
  final _forfeitButtonSubject = PublishSubject<bool>();
  Sink<bool> get forfeitButton => _forfeitButtonSubject.sink;

  MultiBloc(this.repo) : super(repo);

  void setup() async {
    _forfeitButtonSubject.listen((input) => repo.forfeit());
  }

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    switch (event.type) {
      case GameEventType.queue:
        GameState result;
        listenToChallengeMessages();
        listenToMoveMessages();
        listenToWinnerMessages();
        await repo.queuePlayer().catchError((e) {
          result = GameState.error('error queueing to server');
        }).then((game) => showGame(game));
        if (result != null && result.type == GameStateType.error) {
          yield result;
        }
        break;
      case GameEventType.start:
        if (currentState.type == GameStateType.notInit) {
          yield GameState(type: GameStateType.init);
        }
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        // TODO: show info until other player has finished
        break;
      default:
    }
  }

  void showGame(GameOnline game) async {
    _waitMessageSubject.add('Waiting for opponent...');
    gameField = game.gameField;
    targetField = game.targetField;
    _enemyTargetSubject.add(game.enemyTargetField);
    _enemyNameSubject.add(game.enemyName);
    moveNumberSubject.add(game.moves);
    if (game.started) {
      _hasMatchStartedSubject.add(true);
      emitEvent(GameEvent(type: GameEventType.start));
    }
  }

  void listenToChallengeMessages() {
    challengeSub = repo.challengeMessages.listen((mess) {
      repo.storeMatchId(mess.matchId);
      emitEvent(GameEvent(type: GameEventType.start));
    });
  }

  void listenToMoveMessages() {
    moveSub = repo.moveMessages.listen((mess) {
      _enemyTargetSubject.add(TargetField(grid: mess.enemyTarget));
    });
  }

  void listenToWinnerMessages() async {
    String uid = await repo.getStoredUid();
    // TODO: does work, but home_screen is not refreshed
    winnerSub = repo.winnerMessages.listen((mess) {
      if (mess.winner == uid) repo.updateUserInfo();
    });
  }

  @override
  void dispose() async {
    moveSub.cancel();
    challengeSub.cancel();
    winnerSub.cancel();
    _enemyTargetSubject.close();
    _waitMessageSubject.close();
    _enemyNameSubject.close();
    super.dispose();
  }
}
