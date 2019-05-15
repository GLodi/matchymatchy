import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/data/data.dart';

/// Methods available for both Singleplayer and Multiplayer.
abstract class GameRepo {
  final LogicProvider logicProvider;
  final DbProvider dbProvider;
  final SharedPrefsProvider prefsProvider;

  GameRepo({this.logicProvider, this.dbProvider, this.prefsProvider});

  // Apply chosen move and return new field
  Observable<GameField> applyMove(GameField gameField, Move move) =>
      Observable.fromFuture(logicProvider.applyMove(gameField, move))
          .asyncMap((gf) => prefsProvider.increaseMoves())
          .handleError((e) => throw e);

  // Return amount of moves currently played
  Observable<int> getMoves() => Observable.fromFuture(prefsProvider.getMoves())
      .handleError((e) => throw e);

  // Check whether player has reached end game
  Future<bool> isCorrect(GameField gameField, TargetField targetField);
}
