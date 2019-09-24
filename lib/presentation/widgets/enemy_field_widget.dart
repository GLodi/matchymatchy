import 'package:flutter/material.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

const colors = {
  0: Colors.white,
  1: Colors.blue,
  2: Colors.orange,
  3: Colors.yellow,
  4: Colors.green,
  5: Colors.red,
  6: Colors.transparent,
};

class EnemyWidget extends StatefulWidget {
  @override
  _EnemyWidgetState createState() => _EnemyWidgetState();
}

class _EnemyWidgetState extends State<EnemyWidget> {
  EnemyFieldBloc bloc;
  TargetField enemyField = TargetField(grid: "666666666");
  double fifthWidth, tenthWidth;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<EnemyFieldBloc>(context);
    bloc.emitEvent(WidgetEvent(type: WidgetEventType.start));
  }

  @override
  Widget build(BuildContext context) {
    fifthWidth = MediaQuery.of(context).size.width / 5;
    tenthWidth = fifthWidth / 2;
    return StreamBuilder<TargetField>(
      stream: bloc.enemyField,
      initialData: enemyField,
      builder: (context, snapshot) {
        enemyField = snapshot.data;
        return Stack(
          children: <Widget>[
            squareEnemy(0, 0, 2 * tenthWidth),
            squareEnemy(1, tenthWidth, 2 * tenthWidth),
            squareEnemy(2, 2 * tenthWidth, 2 * tenthWidth),
            squareEnemy(3, 0, tenthWidth),
            squareEnemy(4, tenthWidth, tenthWidth),
            squareEnemy(5, 2 * tenthWidth, tenthWidth),
            squareEnemy(6, 0, 0),
            squareEnemy(7, tenthWidth, 0),
            squareEnemy(8, 2 * tenthWidth, 0),
          ],
        );
      },
    );
  }

  Widget squareEnemy(int index, double left, double bottom) {
    return Positioned(
      left: left,
      bottom: bottom,
      width: tenthWidth,
      height: tenthWidth,
      child: Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: colors[int.parse(enemyField.grid[index])],
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
      ),
    );
  }
}
