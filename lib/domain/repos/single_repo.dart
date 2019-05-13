import 'package:rxdart/rxdart.dart';

import 'game_repo.dart';
import 'package:squazzle/data/data.dart';

/// SingleBloc's repository.
class SingleRepo extends GameRepo {
  SingleRepo(LogicProvider logicProvider, DbProvider dbProvider,
      SharedPrefsProvider prefsProvider)
      : super(
            logicProvider: logicProvider,
            dbProvider: dbProvider,
            prefsProvider: prefsProvider);

  @override
  Observable<bool> isCorrect(GameField gameField, TargetField targetField) =>
      Observable.fromFuture(
              logicProvider.checkIfCorrect(gameField, targetField))
          .handleError((e) => throw e);

  Observable<Game> getGame(int id) =>
      Observable.fromFuture(prefsProvider.restoreMoves())
          .asyncMap((_) => dbProvider.getGame(id))
          .handleError((e) => throw e);
}
