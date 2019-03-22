
import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class HomeBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final HomeRepo _repo;

  HomeBloc(this._repo) : super(initialState: SquazzleState.notInit());

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      await _repo.loginWithGoogle()
        .listen((user) {

        }, onError: (e) {

        }, onDone: () {

        }).asFuture();
      yield SquazzleState.init();
    }
  }

}