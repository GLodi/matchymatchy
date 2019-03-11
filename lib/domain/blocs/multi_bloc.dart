import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class MultiBloc extends GameBloc {
  final MultiRepo _repo;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  MultiBloc(this._repo) : super(BehaviorSubject<bool>(), BehaviorSubject<int>());

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      yield SquazzleState.init();
    }
  }
  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}