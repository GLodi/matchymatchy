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
};

class TargetFieldWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TargetFieldWidgetState();
  }
}

class _TargetFieldWidgetState extends State<TargetFieldWidget> {
  TargetBloc bloc;
  double fifthWidth, tenthWidth;
  TargetField target = TargetField(grid: "111111111");

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<TargetBloc>(context);
    bloc.emitEvent(WidgetEvent(type: WidgetEventType.start));
  }

  @override
  Widget build(BuildContext context) {
    fifthWidth = MediaQuery.of(context).size.width / 5;
    tenthWidth = fifthWidth / 2;
    return StreamBuilder<TargetField>(
      stream: bloc.targetField,
      initialData: target,
      builder: (context, snapshot) {
        target = snapshot.data;
        return Stack(
          children: <Widget>[
            squareTarget(0, 0, 2 * tenthWidth),
            squareTarget(1, tenthWidth, 2 * tenthWidth),
            squareTarget(2, 2 * tenthWidth, 2 * tenthWidth),
            squareTarget(3, 0, tenthWidth),
            squareTarget(4, tenthWidth, tenthWidth),
            squareTarget(5, 2 * tenthWidth, tenthWidth),
            squareTarget(6, 0, 0),
            squareTarget(7, tenthWidth, 0),
            squareTarget(8, 2 * tenthWidth, 0),
          ],
        );
      },
    );
  }

  Widget squareTarget(int index, double left, double bottom) {
    return Positioned(
      left: left,
      bottom: bottom,
      width: tenthWidth,
      height: tenthWidth,
      child: Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: colors[int.parse(target.grid[index])],
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
      ),
    );
  }
}
