import 'package:flutter/foundation.dart';

import 'package:matchymatchy/data/models/models.dart';
import 'package:matchymatchy/domain/bloc_utils/bloc_utils.dart';

class HomeMatchListState extends BlocState {
  final HomeMatchListStateType type;
  final String message;
  final List<ActiveMatch> activeMatches;
  final List<PastMatch> pastMatches;
  final User user;

  HomeMatchListState({
    @required this.type,
    this.message,
    this.activeMatches,
    this.pastMatches,
    this.user,
  });

  factory HomeMatchListState.init(List<ActiveMatch> activeMatches,
          List<PastMatch> pastMatches, User user) =>
      HomeMatchListState(
          type: HomeMatchListStateType.init,
          activeMatches: activeMatches,
          pastMatches: pastMatches,
          user: user);

  factory HomeMatchListState.fetching() =>
      HomeMatchListState(type: HomeMatchListStateType.fetching);

  factory HomeMatchListState.empty() =>
      HomeMatchListState(type: HomeMatchListStateType.empty);

  factory HomeMatchListState.error(String message) =>
      HomeMatchListState(type: HomeMatchListStateType.error, message: message);
}

enum HomeMatchListStateType {
  init,
  fetching,
  empty,
  error,
}

class HomeMatchListEvent extends BlocEvent {
  final HomeMatchListEventType type;

  HomeMatchListEvent({this.type: HomeMatchListEventType.start});

  factory HomeMatchListEvent.start() =>
      HomeMatchListEvent(type: HomeMatchListEventType.start);

  factory HomeMatchListEvent.updateMatches() =>
      HomeMatchListEvent(type: HomeMatchListEventType.updateMatches);

  factory HomeMatchListEvent.showMatches() =>
      HomeMatchListEvent(type: HomeMatchListEventType.showMatches);

  factory HomeMatchListEvent.refreshMatches() =>
      HomeMatchListEvent(type: HomeMatchListEventType.refreshMatches);
}

enum HomeMatchListEventType {
  start,
  updateMatches,
  showMatches,
  refreshMatches,
}
