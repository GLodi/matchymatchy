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
  final _matchUpdatesSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get matchUpdates => _matchUpdatesSubject.stream;

  MultiBloc(this.repo) : super(repo);

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
          print(e);
          result = GameState.error('error queueing to server');
        }).then((game) => storeGameInfo(game));
        if (result != null && result.type == GameStateType.error) {
          yield result;
          print("DEBUG: yield error from queue event");
        }
        break;
      case GameEventType.start:
        if (currentState.type == GameStateType.notInit) {
          yield GameState(type: GameStateType.init);
          print("DEBUG: yield init from start event");
        }
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        // TODO show info until other player has finished
        break;
      default:
    }
  }

  void storeGameInfo(Game game) async {
    _waitMessageSubject.add('Waiting for opponent...');
    gameField = game.gameField;
    targetField = game.targetField;
    var diff = repo.diffToSend(gameField, targetField);
    _matchUpdatesSubject.add(diff);
  }

  void listenToChallengeMessages() {
    print("DEBUG: challenge coming");
    challengeSub = repo.challengeMessages.listen((mess) {
      print("DEBUG: challenge here");
      repo.storeMatchId(mess.matchId);
      emitEvent(GameEvent(type: GameEventType.start));
    });
  }

  void listenToMoveMessages() {
    moveSub = repo.moveMessages.listen((mess) {
      _matchUpdatesSubject.add(TargetField(grid: mess.enemyTarget));
    });
  }

  void listenToWinnerMessages() async {
    String uid = await repo.getStoredUid();
    // TODO does work, but home_screen is not refreshed
    winnerSub = repo.winnerMessages.listen((mess) {
      if (mess.winner == uid) repo.updateUserInfo();
    });
  }

  @override
  void dispose() async {
    print("DEBUG: disposed mb");
    moveSub.cancel();
    challengeSub.cancel();
    winnerSub.cancel();
    _matchUpdatesSubject.close();
    _waitMessageSubject.close();
    repo.deleteInstance();
    super.dispose();
  }
}
