import 'package:rxdart/rxdart.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

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
  final BehaviorSubject<bool> correctSubject = new BehaviorSubject<bool>();
  final BehaviorSubject<int> moveNumberSubject = new BehaviorSubject<int>();

  // Used by respective blocs to store the game state and do endgame checks.
  GameField gameField;
  TargetField targetField;

  GameBloc(this.gameRepo) : super(initialState: GameState.notInit());

  @override
  void dispose() {
    correctSubject.close();
    moveNumberSubject.close();
    super.dispose();
  }
}
