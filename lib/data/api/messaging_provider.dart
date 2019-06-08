import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:squazzle/data/models/models.dart';

abstract class MessagingProvider {
  // Return FCM token
  Future<String> getToken();

  // Stream with Challenge messages
  Stream<ChallengeMessage> get challengeMessages;

  // Stream with Move messages
  Stream<MoveMessage> get moveMessages;

  // Stream with Winner messages
  Stream<WinnerMessage> get winnerMessages;
}

class MessagingProviderImpl implements MessagingProvider {
  final _messaging = FirebaseMessaging();
  final StreamController<ChallengeMessage> _challengeSubject =
      StreamController.broadcast();
  final StreamController<MoveMessage> _moveSubject =
      StreamController.broadcast();
  final StreamController<WinnerMessage> _winnerSubject =
      StreamController.broadcast();

  MessagingProviderImpl() {
    _messaging.setAutoInitEnabled(false);
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        var typ = message['data'].cast<String, dynamic>()['messType'];
        switch (typ) {
          case 'challenge':
            _challengeSubject.add(ChallengeMessage.fromMap(message));
            break;
          case 'move':
            _moveSubject.add(MoveMessage.fromMap(message));
            break;
          case 'winner':
            _winnerSubject.add(WinnerMessage.fromMap(message));
            break;
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  @override
  Stream<ChallengeMessage> get challengeMessages => _challengeSubject.stream;

  @override
  Stream<MoveMessage> get moveMessages => _moveSubject.stream;

  @override
  Stream<WinnerMessage> get winnerMessages => _winnerSubject.stream;

  @override
  Future<String> getToken() async => await _messaging.getToken();
}
