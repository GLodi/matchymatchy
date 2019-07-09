import 'package:rxdart/rxdart.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:squazzle/domain/domain.dart';

/// HomeScreen's bloc.
/// Handles profile info and user authentication.
class HomeBloc extends BlocEventStateBase<HomeEvent, HomeState> {
  final HomeRepo _repo;

  // Trigger home_screen -> multi_screen transition
  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  // Show help slides if first time opening app
  final _showSlidesSubject = BehaviorSubject<bool>();
  Stream<bool> get showSlides => _showSlidesSubject.stream;

  // Listen to connection changes
  final _connChangeSub = BehaviorSubject<bool>();
  Stream<bool> get connChange => _connChangeSub.stream;

  // Listen to done button press on last slide (need to hide them)
  final _doneSlidesButtonSubject = PublishSubject<bool>();
  Sink<bool> get doneSlidesButton => _doneSlidesButtonSubject.sink;

  StreamSubscription _connectivitySub;

  HomeBloc(this._repo) : super(initialState: HomeState.notInit());

  void setup() async {
    _doneSlidesButtonSubject.listen((input) {
      _showSlidesSubject.add(input);
    });
    ConnectivityResult curr = await Connectivity().checkConnectivity();
    bool prev = curr == ConnectivityResult.none ? false : true;
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none && prev) {
        _connChangeSub.add(false);
        prev = false;
      }
      if (result != ConnectivityResult.none && !prev) {
        _connChangeSub.add(true);
        prev = true;
      }
    });
  }

  @override
  Stream<HomeState> eventHandler(
      HomeEvent event, HomeState currentState) async* {
    switch (event.type) {
      case HomeEventType.checkIfUserLogged:
        yield await checkIfUserLogged();
        _repo.isFirstOpen().then((b) => _showSlidesSubject.add(b));
        break;
      case HomeEventType.multiButtonPress:
        if (currentState?.type == HomeStateType.initLogged) {
          _intentToMultiScreenSubject.add((null));
        } else {
          yield HomeState.notInit();
          HomeState nextState;
          await _repo.loginWithGoogle().catchError((e) {
            nextState = HomeState.error(e.toString());
          });
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
    await _repo.checkIfLoggedIn().catchError((e) {
      nextState = HomeState.error(e.toString());
    }).then((user) {
      user != null
          ? nextState = HomeState.initLogged(user)
          : nextState = HomeState.initNotLogged();
    });
    return nextState;
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    _showSlidesSubject.close();
    _doneSlidesButtonSubject.close();
    _connectivitySub.cancel();
    super.dispose();
  }
}
