import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';
import 'package:squazzle/data/models/models.dart';

class HomeState extends BlocState {
  final HomeStateType type;
  final String message;
  final User user;

  HomeState({
    @required this.type,
    this.message,
    this.user,
  });

  factory HomeState.initLogged(User user) =>
      HomeState(type: HomeStateType.initLogged, user: user);

  factory HomeState.initNotLogged() =>
      HomeState(type: HomeStateType.initNotLogged);

  factory HomeState.notInit() => HomeState(type: HomeStateType.notInit);
}

enum HomeStateType {
  initLogged,
  initNotLogged,
  notInit,
}

class HomeEvent extends BlocEvent {
  final HomeEventType type;
  final String message;

  HomeEvent({
    this.type: HomeEventType.checkIfUserLogged,
    this.message,
  }) : assert(type != null);
}

enum HomeEventType {
  checkIfUserLogged,
  multiButtonPress,
}
