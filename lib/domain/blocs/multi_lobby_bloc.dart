import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class MultiLobbyBloc extends BlocEventStateBase<SquazzleEvent, SquazzleState>  {
  final MultiLobbyRepo _repo;

  MultiLobbyBloc(this._repo);

  @override
  Stream<SquazzleState> eventHandler(SquazzleEvent event, SquazzleState currentState) {
    if (event.type == SquazzleEventType.start) {

    }
  }

  @override
  void dispose() {
    super.dispose();
  }

}