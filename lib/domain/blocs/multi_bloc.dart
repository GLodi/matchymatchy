import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// In addition to the functionalities available through Gamebloc,
/// the Multiplayer version of the game needs an Enemy
class MultiBloc extends GameBloc {
  final MultiRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _moveSubs, _challengeSubs, _winnerSubs;

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

  MultiBloc(this._repo, this._messEventBus) : super(_repo);

  void setup() {
    _forfeitButtonSubject.listen((input) => _repo.forfeit());
  }

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    switch (event.type) {
      case GameEventType.queue:
        GameState result;
        listenToMessages();
        await _repo.queuePlayer().catchError((e) {
          result = GameState.error('error queueing to server');
        }).then((match) => queueResult(match));
        if (result != null && result.type == GameStateType.error) {
          yield result;
        }
        break;
      case GameEventType.start:
        if (currentState.type == GameStateType.notInit) {
          // TODO: request game info
          yield GameState(type: GameStateType.init);
        }
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        // TODO: show info until other player has finished
        break;
      case GameEventType.error:
        yield GameState.error('Error queueing');
        break;
      default:
    }
  }

  void queueResult(ActiveMatch activeMatch) async {
    _waitMessageSubject.add('Waiting for opponent...');
    if (activeMatch.started == 1) {
      gameField = activeMatch.gameField;
      targetField = activeMatch.targetField;
      _enemyTargetSubject.add(activeMatch.enemyTargetField);
      _enemyNameSubject.add(activeMatch.enemyName);
      moveNumberSubject.add(activeMatch.moves);
      _hasMatchStartedSubject.add(true);
      emitEvent(GameEvent(type: GameEventType.start));
    }
  }

  void listenToMessages() {
    if (_challengeSubs == null && _moveSubs == null && _winnerSubs == null) {
      _challengeSubs =
          _messEventBus.on<ChallengeMessage>().listen((mess) async {
        await _repo
            .queuePlayer()
            .catchError(emitEvent(GameEvent(type: GameEventType.error)))
            .then((match) => queueResult(match));
        await emitEvent(GameEvent(type: GameEventType.start));
      });
      _moveSubs = _messEventBus.on<MoveMessage>().listen((mess) {
        _enemyTargetSubject.add(TargetField(grid: mess.enemyTarget));
      });
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) {
        // TODO: populate win_widget that's already showing, or show if forfeit
        emitEvent(GameEvent(type: GameEventType.victory));
      });
    }
  }

  @override
  void dispose() async {
    _moveSubs.cancel();
    _challengeSubs.cancel();
    _winnerSubs.cancel();
    _enemyTargetSubject.close();
    _waitMessageSubject.close();
    _enemyNameSubject.close();
    _hasMatchStartedSubject.close();
    super.dispose();
  }
}
