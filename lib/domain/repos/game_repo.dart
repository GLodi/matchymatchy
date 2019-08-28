import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/data/data.dart';

/// Methods available to both Singleplayer and Multiplayer.
abstract class GameRepo {
  final LogicProvider logicProvider;
  final DbProvider dbProvider;

  GameRepo({this.logicProvider, this.dbProvider});

  Future<GameField> applyMove(GameField gameField, Move move) {
    increaseMoves();
    return logicProvider.applyMove(gameField, move);
  }

  Future<int> getMoves();

  Future<void> increaseMoves();

  Future<bool> moveDone(GameField gameField, TargetField targetField);
}
