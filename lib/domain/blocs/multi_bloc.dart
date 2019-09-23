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

  final _waitMessageSubject = BehaviorSubject<String>();
  Stream<String> get waitMessage => _waitMessageSubject.stream;

  final _enemyTargetSubject = BehaviorSubject<TargetField>();
  Stream<TargetField> get enemyTarget => _enemyTargetSubject.stream;

  final _hasMatchStartedSubject = BehaviorSubject<bool>();
  Stream<bool> get hasMatchStarted => _hasMatchStartedSubject.stream;

  final _enemyNameSubject = BehaviorSubject<String>();
  Stream<String> get enemyName => _enemyNameSubject.stream;

  final _forfeitButtonSubject = PublishSubject<bool>();
  Sink<bool> get forfeitButton => _forfeitButtonSubject.sink;

  MultiBloc(this._repo, this._messEventBus) : super(_repo);

  void setup() {
    _forfeitButtonSubject.listen((input) => _repo.forfeit());
  }

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    listenToMessages();
    switch (event.type) {
      case GameEventType.start:
        if (currentState.type == GameStateType.notInit) {
          yield GameState(type: GameStateType.init);
        }
        break;
      case GameEventType.queue:
        try {
          ActiveMatch currentMatch = await _repo.queuePlayer();
          fetchResult(currentMatch);
        } catch (e) {
          yield GameState.error('Error queueing');
          print(e);
        }
        break;
      case GameEventType.reconnect:
        try {
          ActiveMatch currentMatch =
              await _repo.reconnectPlayer(event.reconnectMatchId);
          fetchResult(currentMatch);
        } catch (e) {
          yield GameState.error('Error reconnecting to match');
          print(e);
        }
        break;
      case GameEventType.victory:
        correctSubject.add(true);
        break;
      case GameEventType.error:
        yield GameState.error('Error queueing');
        break;
      default:
    }
  }

  void fetchResult(ActiveMatch currentMatch) async {
    _waitMessageSubject.add('Waiting for opponent...');
    if (currentMatch.started == 1) {
      gameField = currentMatch.gameField;
      targetField = currentMatch.targetField;
      _enemyTargetSubject.add(currentMatch.enemyTargetField);
      _enemyNameSubject.add(currentMatch.enemyName);
      moveNumberSubject.add(currentMatch.moves);
      _hasMatchStartedSubject.add(true);
      emitEvent(GameEvent(type: GameEventType.start));
    }
  }

  void listenToMessages() {
    _challengeSubs = _messEventBus.on<ChallengeMessage>().listen((mess) async {
      print('multi challenge');
      _repo
          .queuePlayer()
          .catchError(
              (Object e) => emitEvent(GameEvent(type: GameEventType.error)))
          .then((match) => fetchResult(match));
    });
    _moveSubs = _messEventBus.on<MoveMessage>().listen((mess) {
      _enemyTargetSubject.add(TargetField(grid: mess.enemyTarget));
    });
    _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) {
      emitEvent(GameEvent(type: GameEventType.victory));
    });
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
