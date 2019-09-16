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
  StreamSubscription _connectivitySubs, _challengeSubs, _winnerSubs;

  final _intentToMultiScreenSubject = BehaviorSubject<void>();
  Stream<void> get intentToMultiScreen => _intentToMultiScreenSubject.stream;

  final _activeMatchesSubject = BehaviorSubject<List<ActiveMatch>>();
  Stream<List<ActiveMatch>> get activeMatches => _activeMatchesSubject.stream;

  final _pastMatchesSubject = BehaviorSubject<List<PastMatch>>();
  Stream<List<PastMatch>> get pastMatches => _pastMatchesSubject.stream;

  final _showSlidesSubject = BehaviorSubject<bool>();
  Stream<bool> get showSlides => _showSlidesSubject.stream;

  final _connChangeSub = BehaviorSubject<bool>();
  Stream<bool> get connChange => _connChangeSub.stream;

  final _snackBarSubject = BehaviorSubject<String>();
  Stream<String> get snackBar => _snackBarSubject.stream;

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
            await _repo.loginWithGoogle();
            updateMatches();
            yield await checkIfUserLogged();
          } catch (e) {
            _snackBarSubject.add('Login error');
            print(e);
          }
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
        // TODO: get stored active matches and put them on top
        // TODO: show queue on multi button if there's any active matches
        List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
        List<PastMatch> pastMatches = await _repo.getPastMatches();
        _repo.updateUserInfo();
        String uid = await _repo.getUid();
        nextState = HomeState.initLogged(user, activeMatches, pastMatches);
        _challengeSubs = _messEventBus.on<ChallengeMessage>().listen((mess) {
          print('home challenge');
          // TODO: show option to go to multi
          // TODO: show inmatch on multi button
        });
        _winnerSubs = _messEventBus.on<WinnerMessage>().listen((mess) {
          print('home winnner');
          if (mess.winner == uid) {
            _repo.updateUserInfo();
            // TODO: update wins amount in user_widget
          }
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

  Future<void> updateMatches() async {
    try {
      // TODO: show loading on active/past matches list
      await _repo.updateMatches();
      List<ActiveMatch> activeMatches = await _repo.getActiveMatches();
      List<PastMatch> pastMatches = await _repo.getPastMatches();
      _activeMatchesSubject.add(activeMatches);
      _pastMatchesSubject.add(pastMatches);
    } catch (e) {
      _snackBarSubject.add('Fetching user info error');
      print(e);
    }
  }

  @override
  void dispose() {
    _intentToMultiScreenSubject.close();
    _showSlidesSubject.close();
    _doneSlidesButtonSubject.close();
    _connectivitySubs.cancel();
    _winnerSubs.cancel();
    _challengeSubs.cancel();
    super.dispose();
  }
}
