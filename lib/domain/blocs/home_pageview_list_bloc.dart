import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class HomePageViewListBloc
    extends BlocEventStateBase<HomePageViewListEvent, HomePageViewListState> {
  final HomePageViewListRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _challengeSubs, _winnerSubs;

  HomePageViewListBloc(this._repo, this._messEventBus)
      : super(initialState: HomePageViewListState.fetching());

  @override
  Stream<HomePageViewListState> eventHandler(
      HomePageViewListEvent event, HomePageViewListState currentState) async* {
    switch (event.type) {
      case HomePageViewListEventType.start:
        listenToWinnerMessages();
        emitEvent(HomePageViewListEvent(
            type: HomePageViewListEventType.updateMatches));
        break;
      case HomePageViewListEventType.updateMatches:
        yield HomePageViewListState(type: HomePageViewListStateType.fetching);
        await _repo.updateMatches();
        try {
          List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
          List<PastMatch> pastMatches = await _repo.getPastMatches();
          if (activeMatches.isNotEmpty || pastMatches.isNotEmpty) {
            yield HomePageViewListState(
                type: HomePageViewListStateType.init,
                activeMatches: activeMatches.isNotEmpty ? activeMatches : [],
                pastMatches: pastMatches.isNotEmpty ? pastMatches : []);
          } else {
            yield HomePageViewListState(type: HomePageViewListStateType.empty);
          }
        } catch (e) {
          yield HomePageViewListState(
              type: HomePageViewListStateType.error,
              message: 'Error fetching matches information');
          print(e);
        }
        break;
      default:
    }
  }

  void listenToWinnerMessages() {
    _challengeSubs = _messEventBus.on<ChallengeMessage>().listen((mess) async {
      print('pageviewlist challenge');
      emitEvent(
          HomePageViewListEvent(type: HomePageViewListEventType.updateMatches));
    });
    _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) async {
      print('pageviewlist winner');
      emitEvent(
          HomePageViewListEvent(type: HomePageViewListEventType.updateMatches));
    });
  }

  @override
  void dispose() {
    _challengeSubs.cancel();
    _winnerSubs.cancel();
    super.dispose();
  }
}
