
import 'package:squazzle/domain/domain.dart';

class HomeBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState> {
  final HomeRepo _repo;

  HomeBloc(this._repo);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) {
    if (event.type == SquazzleEventType.start) {
      
    }
  }

}