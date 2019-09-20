import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class HomePageViewListState extends BlocState {
  final HomePageViewStateType type;
  final String message;

  HomePageViewListState({
    @required this.type,
    this.message,
  });

  factory HomePageViewListState.notInit() =>
      HomePageViewListState(type: HomePageViewStateType.notInit);

  factory HomePageViewListState.error(String message) => HomePageViewListState(
      type: HomePageViewStateType.error, message: message);
}

enum HomePageViewStateType {
  notInit,
  error,
}

class HomePageViewListEvent extends BlocEvent {
  final HomePageViewEventType type;

  HomePageViewListEvent({this.type: HomePageViewEventType.start});
}

enum HomePageViewEventType {
  start,
}
