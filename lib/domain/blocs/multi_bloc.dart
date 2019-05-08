import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// In addition to the functionalities available through Gamebloc,
/// the Multiplayer version of the game needs an Enemy
class MultiBloc extends GameBloc {
  final MultiRepo repo;
  final _messaging = FirebaseMessaging();

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
        String token = await _messaging.getToken();
        listenToMatchUpdates();
        await repo
            .queuePlayer(token)
            .handleError((e) {
              print(e);
              result = GameState.error('error queueing to server');
            })
            .listen((game) => storeGameInfo(game))
            .asFuture();
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
        // TODO show info until other player has finished
        repo.sendWinSignal(moves).listen((_) {});
        break;
      default:
    }
  }

  // Listen for Firebase Cloud Messages
  void listenToMatchUpdates() {
    _messaging.setAutoInitEnabled(false);
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        var typ = message['data'].cast<String, dynamic>()['messType'];
        switch (typ) {
          case 'challenge':
            handleChallengeMessage(ChallengeMessage.fromMap(message));
            break;
          case 'move':
            handleMoveMessage(MoveMessage.fromMap(message));
            break;
          case 'winner':
            handleWinnerMessage(WinnerMessage.fromMap(message));
            break;
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void handleChallengeMessage(ChallengeMessage challengeMessage) {
    repo.setMatchId(challengeMessage.matchId);
    emitEvent(GameEvent(type: GameEventType.start));
  }

  void handleMoveMessage(MoveMessage moveMessage) {
    _matchUpdatesSubject.add(TargetField(grid: moveMessage.enemyTarget));
  }

  void handleWinnerMessage(WinnerMessage winnerMessage) async {
    String uid = await repo.getStoredUid().listen((uid) => uid).asFuture();
    // TODO does work, but home_screen is not refreshed
    if (winnerMessage.winner == uid) {
      repo.updateUserInfo();
    }
  }

  void storeGameInfo(Game game) async {
    _waitMessageSubject.add('Waiting for opponent...');
    gameField = game.gameField;
    targetField = game.targetField;
    var diff = repo.diffToSend(gameField, targetField);
    _matchUpdatesSubject.add(diff);
  }

  @override
  void dispose() {
    _matchUpdatesSubject.close();
    _waitMessageSubject.close();
    _messaging.deleteInstanceID();
    super.dispose();
  }
}
