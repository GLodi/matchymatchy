import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class SingleBloc extends GameBloc {
  final SingleRepo _repo;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  SingleBloc(this._repo) : super(BehaviorSubject<bool>(), BehaviorSubject<int>());

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