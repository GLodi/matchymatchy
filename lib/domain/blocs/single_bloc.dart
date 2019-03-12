import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class SingleBloc extends GameBloc {
  final SingleRepo repo;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  SingleBloc(this.repo) : super(repo);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      yield SquazzleState(type: SquazzleStateType.init);
    }
  }

  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}