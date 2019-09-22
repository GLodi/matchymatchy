import 'package:flutter/foundation.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class HomePageViewListState extends BlocState {
  final HomePageViewListStateType type;
  final String message;
  final List<ActiveMatch> activeMatches;
  final List<PastMatch> pastMatches;

  HomePageViewListState({
    @required this.type,
    this.message,
    this.activeMatches,
    this.pastMatches,
  });

  factory HomePageViewListState.init(
          List<ActiveMatch> activeMatches, List<PastMatch> pastMatches) =>
      HomePageViewListState(
          type: HomePageViewListStateType.init,
          activeMatches: activeMatches,
          pastMatches: pastMatches);

  factory HomePageViewListState.fetching() =>
      HomePageViewListState(type: HomePageViewListStateType.fetching);

  factory HomePageViewListState.empty() =>
      HomePageViewListState(type: HomePageViewListStateType.empty);

  factory HomePageViewListState.error(String message) => HomePageViewListState(
      type: HomePageViewListStateType.error, message: message);
}

enum HomePageViewListStateType {
  init,
  fetching,
  empty,
  error,
}

class HomePageViewListEvent extends BlocEvent {
  final HomePageViewListEventType type;

  HomePageViewListEvent({this.type: HomePageViewListEventType.start});
}

enum HomePageViewListEventType {
  start,
  updateMatches,
}
