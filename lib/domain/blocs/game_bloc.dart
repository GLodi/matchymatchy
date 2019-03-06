import 'package:squazzle/data/models/models.dart';

abstract class GameBloc {
  Stream<GameField> get gameField;
  Stream<TargetField> get targetField;
  Stream<bool> get correct;
  Stream<int> get moveNumber;
  Sink<List<int>> get move;
}