import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class MultiBloc extends GameBloc {
  final MultiRepo repo;

  Stream<bool> get correct => correctSubject.stream;
  Stream<int> get moveNumber => moveNumberSubject.stream;

  MultiBloc(this.repo) : super(repo);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
    }
  }
  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}