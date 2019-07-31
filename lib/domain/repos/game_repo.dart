import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/data/data.dart';

/// Methods available to both Singleplayer and Multiplayer.
abstract class GameRepo {
  final LogicProvider logicProvider;
  final DbProvider dbProvider;
  final SharedPrefsProvider prefsProvider;

  GameRepo({this.logicProvider, this.dbProvider, this.prefsProvider});

  // Apply chosen move and return new field
  Future<GameField> applyMove(GameField gameField, Move move) => prefsProvider
      .increaseMoves()
      .then((_) => logicProvider.applyMove(gameField, move));

  // TODO: move this to single and multi, logic is different
  // Return amount of moves currently played
  Future<int> getMoves() => prefsProvider.getMoves();

  // Check whether player has reached end game
  Future<bool> moveDone(GameField gameField, TargetField targetField);
}
