import 'package:flutter/foundation.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class HomePageViewState extends BlocState {
  final HomePageViewStateType type;
  final String message;

  HomePageViewState({
    @required this.type,
    this.message,
  });

  factory HomePageViewState.notInit() =>
      HomePageViewState(type: HomePageViewStateType.notInit);

  factory HomePageViewState.error(String message) =>
      HomePageViewState(type: HomePageViewStateType.error, message: message);
}

enum HomePageViewStateType {
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
