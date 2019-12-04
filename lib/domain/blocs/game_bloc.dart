import 'package:rxdart/rxdart.dart';

import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/data/models/models.dart';

/// Abstract class used by both Single Player and Multy Player.
/// It offers an abstraction over all elements that a game
/// needs in order to work.
abstract class GameBloc extends BlocEventStateBase<GameEvent, GameState> {
  /*
    GameRepo is extended by MultiRepo e SingleRepo, as
    they need different ways to handle things.
  */
  final GameRepo gameRepo;

  /*
    BehaviorSubjects offer a way for game widgets to
    react to game changes:
      - correctSubject emits a boolean when the game is over
        because the player has completed the target.
      - moveNumberSubject emits the amount of moves currently used.
  */
  final BehaviorSubject<int> moveNumberSubject = BehaviorSubject<int>();
  final BehaviorSubject<void> intentToWinScreenSubject =
      BehaviorSubject<void>();

  // Used by respective blocs to store the game state and do endgame checks.
  GameField gameField;
  TargetField targetField;

  GameBloc(this.gameRepo) : super(initialState: GameState.notInit());

  void winCheck(GameField gf, TargetField tf);

  @override
  void dispose() {
    intentToWinScreenSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}
