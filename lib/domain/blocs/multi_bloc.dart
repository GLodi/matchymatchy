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

  final _enemyMovesSubject = BehaviorSubject<int>();
  Stream<int> get enemyMoves => _enemyMovesSubject.stream;

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
      case GameEventType.start:
        if (currentState.type == GameStateType.notInit) {
          yield GameState(type: GameStateType.init);
        }
        break;
      case GameEventType.queue:
        try {
          listenToMessages();
          ActiveMatch currentMatch = await _repo.queuePlayer();
          fetchResult(currentMatch);
        } catch (e) {
          yield GameState.error('Error queueing');
          print(e);
        }
        break;
      case GameEventType.connect:
        try {
          listenToMessages();
          ActiveMatch currentMatch =
              await _repo.connectPlayer(event.connectMatchId);
          fetchResult(currentMatch);
        } catch (e) {
          yield GameState.error('Error connecting to match');
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
    if (_challengeSubs == null && _moveSubs == null && _winnerSubs == null) {
      _challengeSubs = _messEventBus.on<ChallengeMessage>().listen((mess) {
        if (_repo.matchId == mess.matchId) {
          print('multi challenge');
          emitEvent(GameEvent(
              type: GameEventType.connect, connectMatchId: mess.matchId));
        }
      });
      _moveSubs = _messEventBus.on<MoveMessage>().listen((mess) {
        if (_repo.matchId == mess.matchId) {
          _enemyMovesSubject.add(mess.enemyMoves);
          _enemyTargetSubject.add(TargetField(grid: mess.enemyTarget));
        }
      });
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) {
        if (_repo.matchId == mess.matchId) {
          print('multi winner');
          emitEvent(GameEvent(type: GameEventType.victory));
        }
      });
    }
  }

  @override
  void dispose() {
    _challengeSubs.cancel();
    _moveSubs.cancel();
    _winnerSubs.cancel();
    super.dispose();
  }
}
