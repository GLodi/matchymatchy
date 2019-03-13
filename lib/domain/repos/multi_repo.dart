import 'package:rxdart/rxdart.dart';

import 'package:squazzle/data/data.dart';
import 'game_repo.dart';

class MultiRepo extends GameRepo {
  final ApiProvider _apiRepo;

  MultiRepo(this._apiRepo);

  @override
  Observable<Game> getGame() => null;

  @override
  Observable<GameField> getGameField() =>
      Observable.fromFuture(_apiRepo.getDb());

  @override
  Observable<TargetField> getTargetField() => null;

  @override
  Observable<GameField> applyMove(Move move) => null;

  @override
  Observable<bool> checkIfCorrect() => null;

  @override
  Observable<int> getMovesAmount() => null;


}