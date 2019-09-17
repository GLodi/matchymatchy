import 'package:flutter/foundation.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class HomePageViewState extends BlocState {
  final HomePageViewStateType type;
  final String message;
  final List<ActiveMatch> activeMatches;
  final List<PastMatch> pastMatches;

  HomePageViewState({
    @required this.type,
    this.message,
    this.activeMatches,
    this.pastMatches,
  });

  factory HomePageViewState.init(
          List<ActiveMatch> activeMatches, List<PastMatch> pastMatches) =>
      HomePageViewState(
          type: HomePageViewStateType.init,
          activeMatches: activeMatches,
          pastMatches: pastMatches);

  factory HomePageViewState.notInit() =>
      HomePageViewState(type: HomePageViewStateType.notInit);

  factory HomePageViewState.error(String message) =>
      HomePageViewState(type: HomePageViewStateType.error, message: message);
}

enum HomePageViewStateType {
  init,
  notInit,
  error,
}

class HomePageViewEvent extends BlocEvent {
  final HomePageViewEventType type;

  HomePageViewEvent({this.type: HomePageViewEventType.start});
}

enum HomePageViewEventType {
  start,
  error,
}
