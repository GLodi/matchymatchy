import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/data/api/exceptions.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// In addition to the functionalities available through Gamebloc,
/// the Multiplayer version of the game needs an Enemy
class MultiBloc extends GameBloc {
  final MultiRepo repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _moveSubs, _challengeSubs, _winnerSubs;

  // Streams extracted from GameBloc's subjects
  Stream<int> get moveNumber => moveNumberSubject.stream;
  Stream<void> get intentToWinScreen => intentToWinScreenSubject.stream;

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

  MultiBloc(this.repo, this._messEventBus) : super(repo);

  void setup() {
    _forfeitButtonSubject.listen((_) {
      try {
        repo.forfeit();
        _messEventBus.forfeitMatch(repo.matchId);
      } catch (e) {
        emitEvent(GameEvent(type: GameEventType.error));
        print(e);
      }
    });
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
          ActiveMatch currentMatch = await repo.queuePlayer();
          fetchResult(currentMatch);
        } catch (e) {
          yield GameState.error('error queueing');
          print(e);
        }
        break;
      case GameEventType.connect:
        try {
          listenToMessages();
          // TODO: either move to observing firestore or repeat
          // this multiple times
          ActiveMatch currentMatch =
              await repo.connectPlayer(event.connectMatchId);
          fetchResult(currentMatch);
        } catch (e) {
          yield GameState.error('error connecting to match');
          print(e);
        }
        break;
      case GameEventType.matchNotFound:
        yield GameState.notInit();
        _waitMessageSubject.add('lost connection, reconnecting...');
        // TODO: show loading and then try to reconnect,
        // otherwise show error

        break;
      case GameEventType.error:
        yield GameState.error('error');
        break;
      default:
    }
  }

  @override
  void winCheck(GameField gf, TargetField tf) async {
    try {
      bool isCorrect = await repo.moveDone(gf, tf);
      if (isCorrect) intentToWinScreenSubject.add(null);
    } on DataNotAvailableException {
      emitEvent(GameEvent(type: GameEventType.matchNotFound));
    } catch (e) {
      emitEvent(GameEvent(type: GameEventType.error));
    }
  }

  void fetchResult(ActiveMatch currentMatch) async {
    _waitMessageSubject.add('waiting for opponent...');
    if (currentMatch.started == 1) {
      gameField = currentMatch.gameField;
      targetField = currentMatch.targetField;
      _enemyTargetSubject.add(currentMatch.enemyTargetField);
      _enemyNameSubject.add(currentMatch.enemyName);
      _enemyMovesSubject.add(currentMatch.enemyMoves);
      moveNumberSubject.add(currentMatch.moves);
      _hasMatchStartedSubject.add(true);
      emitEvent(GameEvent(type: GameEventType.start));
    }
  }

  void listenToMessages() {
    if (_challengeSubs == null && _moveSubs == null && _winnerSubs == null) {
      _challengeSubs = _messEventBus.on<ChallengeMessage>().listen((mess) {
        if (repo.matchId == mess.matchId) {
          print('multi challenge');
          emitEvent(GameEvent(
              type: GameEventType.connect, connectMatchId: mess.matchId));
        }
      });
      _moveSubs = _messEventBus.on<MoveMessage>().listen((mess) {
        if (repo.matchId == mess.matchId) {
          // TODO: check match not won
          print('multi message');
          _enemyMovesSubject.add(mess.enemyMoves);
          _enemyTargetSubject.add(TargetField(grid: mess.enemyTarget));
        }
      });
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) {
        if (repo.matchId == mess.matchId) {
          print('multi winner');
          intentToWinScreenSubject.add(null);
        }
      });
    }
  }

  @override
  void dispose() {
    _hasMatchStartedSubject.close();
    _waitMessageSubject.close();
    _enemyMovesSubject.close();
    _enemyTargetSubject.close();
    _enemyNameSubject.close();
    _challengeSubs.cancel();
    _moveSubs.cancel();
    _winnerSubs.cancel();
    super.dispose();
  }
}
