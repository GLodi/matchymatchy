import 'package:squazzle/domain/domain.dart';

class SquazzleBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final SquazzleManager _manager;

  SquazzleBloc(this._manager) :
        super(initialState: SquazzleState.notInit());

  void setup() {

  }

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) async* {
    if (event.type == SquazzleEventType.start) {
      SquazzleState result;
      await _manager.getGame().listen((field) => result = SquazzleState.init(field) ).asFuture();
      yield result;
    }
  }
}