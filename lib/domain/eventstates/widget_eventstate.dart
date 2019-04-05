import 'package:flutter/foundation.dart';

import 'package:squazzle/domain/bloc_utils/bloc_utils.dart';

class WidgetState extends BlocState {
  final WidgetStateType type;
  final String message;

  WidgetState({
    @required this.type,
    this.message,
  });

  factory WidgetState.init() => WidgetState(type: WidgetStateType.init);
}

enum WidgetStateType {
  init,
}

class WidgetEvent extends BlocEvent {
  final WidgetEventType type;

  WidgetEvent({this.type: WidgetEventType.start}) : assert(type != null);
}

enum WidgetEventType {
  start,
}
