import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';

class HomeBloc extends BlocEventStateBase<HomeEvent, HomeState> {
  final HomeRepo _repo;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  final _showSlidesSubject = BehaviorSubject<bool>();
  Stream<bool> get showSlides => _showSlidesSubject.stream;

  final _doneSlidesButtonSubject = PublishSubject<bool>();
  Sink<bool> get doneSlidesButton => _doneSlidesButtonSubject.sink;

  HomeBloc(this._repo) : super(initialState: HomeState.notInit());

  void setup() {
    _doneSlidesButtonSubject.listen(_doneSlidesButtonPressed);
  }

  void _doneSlidesButtonPressed(bool input) {
    _showSlidesSubject.add(input);
  }

  @override
  Stream<HomeState> eventHandler(
      HomeEvent event, HomeState currentState) async* {
    switch (event.type) {
      case HomeEventType.checkIfUserLogged:
        yield HomeState.notInit();
        yield await checkIfUserLogged();
        _repo.isFirstOpen().listen((b) => _showSlidesSubject.add(b));
        break;
      case HomeEventType.multiButtonPress:
        if (currentState?.type == HomeStateType.initLogged) {
          _intentToMultiScreenSubject.add((null));
        } else {
          yield HomeState.notInit();
          HomeState nextState;
          await _repo
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
    await _repo.checkIfLoggedIn().handleError((e) {
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
    _showSlidesSubject.close();
    _doneSlidesButtonSubject.close();
    super.dispose();
  }
}
