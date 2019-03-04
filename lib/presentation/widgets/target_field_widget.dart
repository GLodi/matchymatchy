import 'package:flutter/material.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

const colors = {
  0:Colors.white,
  1:Colors.blue,
  2:Colors.orange,
  3:Colors.yellow,
  4:Colors.green,
  5:Colors.red,
};

class TargetFieldWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TargetFieldWidgetState();
  }
}

class _TargetFieldWidgetState extends State<TargetFieldWidget> {
  SingleBloc bloc;
  double fifthWidth, tenthWidth;
  TargetField target = TargetField(grid: [
    [1,1,1],
    [1,1,1],
    [1,1,1],
  ]);

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<SingleBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    fifthWidth = MediaQuery.of(context).size.width/5;
    tenthWidth = fifthWidth/2;
    return StreamBuilder<TargetField>(
      stream: bloc.targetField,
      initialData: target,
      builder: (context, snapshot) {
        target = snapshot.data;
        return Stack(
          children: <Widget>[
            squareTarget(0, 0, 0),
            squareTarget(1, tenthWidth, 0),
            squareTarget(2, 2*tenthWidth, 0),
            squareTarget(3, 0, tenthWidth),
            squareTarget(4, tenthWidth, tenthWidth),
            squareTarget(5, 2*tenthWidth, tenthWidth),
            squareTarget(6, 0, 2*tenthWidth),
            squareTarget(7, tenthWidth, 2*tenthWidth),
            squareTarget(8, 2*tenthWidth, 2*tenthWidth),
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
            color: colors[target.grid[(index/3).truncate()][index%3]],
            borderRadius: BorderRadius.all(Radius.circular(5.0))
        ),
      ),
    );
  }
}