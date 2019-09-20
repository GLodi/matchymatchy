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
      : super(initialState: HomePageViewListState.notInit());

  @override
  Stream<HomePageViewListState> eventHandler(
      HomePageViewListEvent event, HomePageViewListState currentState) async* {
    switch (event.type) {
      case HomePageViewEventType.start:
        List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
        List<PastMatch> pastMatches = await _repo.getPastMatches();
        if (activeMatches != null) _activeMatchesSubject.add(activeMatches);
        if (pastMatches != null) _pastMatchesSubject.add(pastMatches);
        _repo.newActiveMatches
            .listen((list) => _activeMatchesSubject.add(list));
        _repo.newPastMatches.listen((list) => _pastMatchesSubject.add(list));
        break;
      default:
    }
  }
}
