import 'package:rxdart/rxdart.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:matchymatchy/data/api/mess_event_bus.dart';
import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/data/models/models.dart';

/// HomeScreen's bloc.
/// Handles profile info and user authentication.
class HomeBloc extends BlocEventStateBase<HomeEvent, HomeState> {
  final HomeRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _connectivitySubs, _challengeSubs, _winnerSubs;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  final _showSlidesSubject = BehaviorSubject<bool>();
  Stream<bool> get showSlides => _showSlidesSubject.stream;

  final _connChangeSub = BehaviorSubject<bool>();
  Stream<bool> get connChange => _connChangeSub.stream;

  final _snackBarSubject = BehaviorSubject<String>();
  Stream<String> get snackBar => _snackBarSubject.stream;

  final _userSubject = BehaviorSubject<User>();
  Stream<User> get user => _userSubject.stream;

  final _doneSlidesButtonSubject = PublishSubject<bool>();
  Sink<bool> get doneSlidesButton => _doneSlidesButtonSubject.sink;

  final _logoutButtonSubject = PublishSubject<bool>();
  Sink<bool> get logoutButton => _logoutButtonSubject.sink;

  HomeBloc(this._repo, this._messEventBus)
      : super(initialState: HomeState.notInit());

  void setup() async {
    _doneSlidesButtonSubject.listen((input) {
      _showSlidesSubject.add(input);
    });
    _logoutButtonSubject.listen((input) {
      emitEvent(HomeEvent.logoutButtonPress());
    });
    ConnectivityResult curr = await Connectivity().checkConnectivity();
    bool prev = curr == ConnectivityResult.none ? false : true;
    _connChangeSub.add(prev);
    _connectivitySubs = Connectivity()
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
          try {
            await _repo.loginWithGoogle(await _messEventBus.getToken());
            yield await checkIfUserLogged();
          } catch (e) {
            _snackBarSubject.add('login error');
            emitEvent(HomeEvent.checkIfUserLogged());
            print(e);
          }
        }
        break;
      case HomeEventType.logoutButtonPress:
        yield HomeState.notInit();
        await _repo.logout();
        yield await checkIfUserLogged();
        break;
      default:
    }
  }

  Future<HomeState> checkIfUserLogged() async {
    HomeState nextState;
    try {
      User user = await _repo.checkIfLoggedIn();
      if (user != null) {
        listenToMessages();
        nextState = HomeState.initLogged(user);
      } else {
        nextState = HomeState.initNotLogged();
      }
    } catch (e) {
      _snackBarSubject.add('login check error');
      nextState = HomeState.initNotLogged();
      print(e);
    }
    return nextState;
  }

  void listenToMessages() async {
    if (_challengeSubs == null && _winnerSubs == null) {
      String uid = await _repo.getUid();
      _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) async {
        if (mess.winner == uid) {
          await _repo.updateUser();
          _userSubject.add(await _repo.getUser());
        }
      });
    }
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    _showSlidesSubject.close();
    _connChangeSub.close();
    _snackBarSubject.close();
    _userSubject.close();
    _doneSlidesButtonSubject.close();
    if (_connectivitySubs != null) _connectivitySubs.cancel();
    if (_winnerSubs != null) _winnerSubs.cancel();
    if (_challengeSubs != null) _challengeSubs.cancel();
    super.dispose();
  }
}
