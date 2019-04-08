import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// In addition to the functionalities available through Gamebloc,
/// the Multiplayer version of the game needs an Enem
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
        String uid;
        await repo.getStoredUid().handleError((e) {
          print(e);
          result = GameState.error('error retrieving uid from shared prefs');
        }).listen((uuid) {
          uid = uuid;
        }).asFuture();
        if (uid != null) {
          String token = await _messaging.getToken();
          await repo
              .queuePlayer(uid, token)
              .handleError((e) {
                print(e);
                result = GameState.error('error queueing to server');
              })
              .listen((game) => storeGameInfo(game))
              .asFuture();
          listenToMatchUpdates();
        }
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
        // TODO handle victory
        break;
      default:
    }
  }

  void listenToMatchUpdates() {
    _messaging.setAutoInitEnabled(false);
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        Message mesObj = Message.fromMap(message);
        if (mesObj.notiBody != null && mesObj.notiTitle != null) {
          repo.setMatchId(mesObj.matchId);
          emitEvent(GameEvent(type: GameEventType.start));
        } else {
          _matchUpdatesSubject.add(TargetField(grid: mesObj.enemyTarget));
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

  void storeGameInfo(Game game) async {
    _waitMessageSubject.add('Waiting for opponent...');
    gameField = game.gameField;
    targetField = game.targetField;
    await repo.diffToSend(gameField, targetField).listen((diff) {
          _matchUpdatesSubject.add(diff);
    }).asFuture();
  }

  @override
  void dispose() {
    _matchUpdatesSubject.close();
    _waitMessageSubject.close();
    _messaging.deleteInstanceID();
    super.dispose();
  }
}
