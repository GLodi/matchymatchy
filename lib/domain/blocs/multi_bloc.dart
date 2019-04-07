import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiBloc extends GameBloc {
  final MultiRepo repo;
  final messaging = FirebaseMessaging();
  GameField gameField;
  TargetField targetField;
  TargetField enemyField;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  final _waitMessageSubject = BehaviorSubject<String>();
  Stream<String> get waitMessage => _waitMessageSubject.stream;
  final _matchUpdatesSubject = BehaviorSubject<MatchUpdate>();
  Stream<MatchUpdate> get matchUpdates => _matchUpdatesSubject.stream;

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
          String token = await messaging.getToken();
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
    messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        _matchUpdatesSubject
            .add(MatchUpdate.fromMap(message['data'].cast<String, dynamic>()));
        emitEvent(GameEvent(type: GameEventType.start));
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
    enemyField = await repo
        .diffToSend(gameField, targetField)
        .listen((diff) => diff)
        .asFuture();
  }

  @override
  void dispose() {
    _matchUpdatesSubject.close();
    _waitMessageSubject.close();
    super.dispose();
  }
}
