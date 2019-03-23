
import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

class HomeBloc extends BlocEventStateBase<HomeEvent, HomeState> {
  final HomeRepo _repo;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;
 
  HomeBloc(this._repo) : super(initialState: HomeState.notInit());

  @override
  Stream<HomeState> eventHandler(HomeEvent event, HomeState currentState) async* {
    switch (event.type) {
      case HomeEventType.checkIfUserLogged:
        yield HomeState.notInit();
        yield await checkIfUserLogged();
        break;
      case HomeEventType.multiButtonPress:
        yield HomeState.notInit();
        HomeState nextState;
        User user;
        await _repo.checkIfLoggedIn()
          .handleError((e) { nextState = HomeState.error(e.toString()); })
          .listen((user) { user = user; })
          .asFuture();
        if (nextState?.type == HomeStateType.error) {
          yield nextState;
          break;
        }
        if (user != null) {
          _intentToMultiScreenSubject.add((null));
          break;
        } else {
          await _repo.loginWithGoogle()
            .handleError((e) { nextState = HomeState.error(e.toString()); })
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
    await _repo.checkIfLoggedIn()
      .handleError((e) { nextState = HomeState.error(e.toString()); })
      .listen((user) { 
        user != null ? 
          nextState = HomeState.initLogged(user) : 
          nextState = HomeState.initNotLogged();
      }).asFuture();
    return nextState;
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    super.dispose();
  }

}