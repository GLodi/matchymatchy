import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:squazzle/data/models/models.dart';

class MessagingEventBus {
  final FirebaseMessaging _messaging = FirebaseMessaging();
  final StreamController _messController = StreamController.broadcast();

  MessagingEventBus() {
    _messaging.setAutoInitEnabled(false);
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        var typ = message['data'].cast<String, dynamic>()['messType'];
        switch (typ) {
          case 'challenge':
            _messController.add(ChallengeMessage.fromMap(message));
            break;
          case 'move':
            _messController.add(MoveMessage.fromMap(message));
            break;
          case 'winner':
            _messController.add(WinnerMessage.fromMap(message));
            break;
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        var typ = message['data'].cast<String, dynamic>()['messType'];
        switch (typ) {
          case 'challenge':
            _messController.add(ChallengeMessage.fromMap(message));
            break;
          case 'move':
            _messController.add(MoveMessage.fromMap(message));
            break;
          case 'winner':
            _messController.add(WinnerMessage.fromMap(message));
            break;
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  Stream<T> on<T>() {
    return T == dynamic
        ? _messController.stream
        : _messController.stream.where((event) => event is T).cast<T>();
  }

  void forfeitMatch(String matchId) {
    _messController.add(ForfeitMessage(matchId));
  }

  void refreshMatchList() {
    _messController.add(RefreshMessage());
  }

  Future<String> getToken() => _messaging.getToken();
}
