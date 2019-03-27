import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class HomeBloc extends BlocEventStateBase<HomeEvent, HomeState> {
  final HomeManager _manager;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  HomeBloc(this._manager) : super(initialState: HomeState.notInit());

  @override
  Stream<HomeState> eventHandler(
      HomeEvent event, HomeState currentState) async* {
    switch (event.type) {
      case HomeEventType.checkIfUserLogged:
        yield HomeState.notInit();
        yield await checkIfUserLogged();
        break;
      case HomeEventType.multiButtonPress:
        if (currentState?.type == HomeStateType.initLogged) {
          _intentToMultiScreenSubject.add((null));
        } else {
          yield HomeState.notInit();
          HomeState nextState;
          await _manager
              .loginWithGoogle()
              .handleError((e) {
                nextState = HomeState.error(e.toString());
              })
              .listen((_) {})
              .asFuture();
          if (nextState?.type == HomeStateType.error) {
            yield nextState;
            break;
          }
          yield await checkIfUserLogged();
          _intentToMultiScreenSubject.add((null));
        }
        break;
      case HomeEventType.error:
        yield HomeState.error(event.message);
        break;
      default:
    }
  }

  Future<HomeState> checkIfUserLogged() async {
    HomeState nextState;
    await _manager.checkIfLoggedIn().handleError((e) {
      nextState = HomeState.error(e.toString());
    }).listen((user) {
      user != null
          ? nextState = HomeState.initLogged(user)
          : nextState = HomeState.initNotLogged();
    }).asFuture();
    return nextState;
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    super.dispose();
  }
}
