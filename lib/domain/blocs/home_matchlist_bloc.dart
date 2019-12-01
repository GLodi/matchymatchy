import 'dart:async';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class HomeMatchListBloc
    extends BlocEventStateBase<HomeMatchListEvent, HomeMatchListState> {
  final HomeMatchListRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _forfeitSubs, _challengeSubs, _winnerSubs, _refreshSubs;

  HomeMatchListBloc(this._repo, this._messEventBus)
      : super(initialState: HomeMatchListState.fetching());

  @override
  Stream<HomeMatchListState> eventHandler(
      HomeMatchListEvent event, HomeMatchListState currentState) async* {
    switch (event.type) {
      case HomeMatchListEventType.start:
        listenToMessages();
        emitEvent(HomeMatchListEvent.updateMatches());
        break;
      case HomeMatchListEventType.updateMatches:
        yield HomeMatchListState(type: HomeMatchListStateType.fetching);
        try {
          await Future.wait(
              [_repo.updateActiveMatches(), _repo.updatePastMatches()]);
          emitEvent(HomeMatchListEvent.showMatches());
        } catch (e) {
          yield HomeMatchListState(
              type: HomeMatchListStateType.error,
              message: 'error updating matches');
          print(e);
        }
        break;
      case HomeMatchListEventType.refreshMatches:
        yield HomeMatchListState(type: HomeMatchListStateType.fetching);
        emitEvent(HomeMatchListEvent.showMatches());
        break;
      case HomeMatchListEventType.showMatches:
        List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
        List<PastMatch> pastMatches = await _repo.getPastMatches();
        if (activeMatches.isNotEmpty || pastMatches.isNotEmpty) {
          User user = await _repo.getUser();
          yield HomeMatchListState(
            type: HomeMatchListStateType.init,
            activeMatches: activeMatches.isNotEmpty ? activeMatches : [],
            pastMatches: pastMatches.isNotEmpty ? pastMatches : [],
            user: user,
          );
        } else {
          yield HomeMatchListState(type: HomeMatchListStateType.empty);
        }
        break;
      default:
    }
  }

  void listenToMessages() {
    if (_challengeSubs == null && _winnerSubs == null && _forfeitSubs == null) {
      _challengeSubs = _messEventBus.on<ChallengeMessage>().listen((_) async {
        print('matchlist challenge');
        emitEvent(HomeMatchListEvent.updateMatches());
      });
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((_) async {
        print('matchlist winner');
        emitEvent(HomeMatchListEvent.updateMatches());
      });
      _forfeitSubs = _messEventBus.on<ForfeitMessage>().listen((forf) async {
        print('matchlist forfeit');
        // TODO: don't delete, just update it, need to get info for winwidget
        await _repo.deleteActiveMatch(forf.matchId);
        emitEvent(HomeMatchListEvent.refreshMatches());
      });
      _refreshSubs = _messEventBus.on<RefreshMessage>().listen((_) async {
        print('matchlist refresh');
        emitEvent(HomeMatchListEvent.refreshMatches());
      });
    }
  }

  @override
  void dispose() {
    _challengeSubs.cancel();
    _winnerSubs.cancel();
    _forfeitSubs.cancel();
    _refreshSubs.cancel();
    super.dispose();
  }
}
