import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class HomePageViewListBloc
    extends BlocEventStateBase<HomePageViewListEvent, HomePageViewListState> {
  final HomePageViewListRepo _repo;

  final _activeMatchesSubject = BehaviorSubject<List<ActiveMatch>>();
  Stream<List<ActiveMatch>> get activeMatches => _activeMatchesSubject.stream;

  final _pastMatchesSubject = BehaviorSubject<List<PastMatch>>();
  Stream<List<PastMatch>> get pastMatches => _pastMatchesSubject.stream;

  HomePageViewListBloc(this._repo)
      : super(initialState: HomePageViewListState.fetching());

  @override
  Stream<HomePageViewListState> eventHandler(
      HomePageViewListEvent event, HomePageViewListState currentState) async* {
    switch (event.type) {
      case HomePageViewEventType.start:
        yield HomePageViewListState(type: HomePageViewListStateType.fetching);
        try {
          _repo.newActiveMatches
              .listen((list) => _activeMatchesSubject.add(list));
          _repo.newPastMatches.listen((list) => _pastMatchesSubject.add(list));
          List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
          List<PastMatch> pastMatches = await _repo.getPastMatches();
          if (areListsNotEmpty(activeMatches, pastMatches)) {
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
        }
        break;
      default:
    }
  }

  bool areListsNotEmpty(
      List<ActiveMatch> activeMatches, List<PastMatch> pastMatches) {
    return (activeMatches != null && activeMatches.isNotEmpty) ||
        (pastMatches != null && pastMatches.isNotEmpty);
  }
}
