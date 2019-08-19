import 'package:rxdart/rxdart.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:squazzle/data/api/mess_event_bus.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

/// HomeScreen's bloc.
/// Handles profile info and user authentication.
class HomeBloc extends BlocEventStateBase<HomeEvent, HomeState> {
  final HomeRepo _repo;
  final MessagingEventBus _messEventBus;
  StreamSubscription _connectivitySub, _messSub;

  // Trigger home_screen -> multi_screen transition
  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  // Show help slides if first time opening app
  final _showSlidesSubject = BehaviorSubject<bool>();
  Stream<bool> get showSlides => _showSlidesSubject.stream;

  // Listen to connection changes
  final _connChangeSub = BehaviorSubject<bool>();
  Stream<bool> get connChange => _connChangeSub.stream;

  // Show snackbar for login errors
  final _snackBarSubject = BehaviorSubject<String>();
  Stream<String> get snackBar => _snackBarSubject.stream;

  // Listen to done button press on last slide (need to hide them)
  final _doneSlidesButtonSubject = PublishSubject<bool>();
  Sink<bool> get doneSlidesButton => _doneSlidesButtonSubject.sink;

  HomeBloc(this._repo, this._messEventBus)
      : super(initialState: HomeState.notInit());

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
          await _repo.loginWithGoogle().catchError((e) {
            _snackBarSubject.add('Login error');
          });
          yield await checkIfUserLogged();
        }
        break;
      default:
    }
  }

  Future<HomeState> checkIfUserLogged() async {
    HomeState nextState;
    try {
      User user = await _repo.checkIfLoggedIn();
      if (user != null) {
        List<MatchOnline> matches = await _repo.getMatches();
        String uid = await _repo.getStoredUid();
        nextState = HomeState.initLogged(user, matches);
        _messEventBus.on<ChallengeMessage>().listen((mess) {
          print('challenge');
          // TODO: store new mathonline
        });
        _messEventBus.on<WinnerMessage>().listen((mess) {
          print('RECEIVERWINONHOME');
          if (mess.winner == uid) {
            _repo.updateUserInfo();
          }
          // TODO: update match online
          // TODO: update user info
          // TODO: update wins amount in user_widget
          // TODO: show queueing/notqueueing/inmatch on multi button
        });
      } else {
        nextState = HomeState.initNotLogged();
      }
    } catch (e) {
      _snackBarSubject.add('Login check error');
      nextState = HomeState.initNotLogged();
      print(e);
    }
    return nextState;
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    _showSlidesSubject.close();
    _doneSlidesButtonSubject.close();
    _connectivitySub.cancel();
    _messSub.cancel();
    super.dispose();
  }
}
