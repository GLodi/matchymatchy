import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';

const colors = {
  1:Colors.white,
  2:Colors.blue,
  3:Colors.orange,
  4:Colors.yellow,
  5:Colors.green,
  6:Colors.red,
};

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  SquazzleBloc bloc;
  String move;
  List<GlobalKey> keys = List();
  List<Tween> _switchTween = List();
  List<Animation> _switchAnim = List();
  List<AnimationController> _switchAnimCont = List();
  double fifthWidth, tenthWidth, opacityLevel = 1;
  GameField field = GameField(grid: [
    [1,1,1,1,1],
    [1,1,1,1,1],
    [1,1,1,1,1],
    [1,1,1,1,1],
    [1,1,1,1,1],
  ]);
  TargetField target = TargetField(grid: [
    [1,1,1],
    [1,1,1],
    [1,1,1],
  ]);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 25; i++) keys.add(GlobalKey(debugLabel: '$i'));
    bloc = BlocProvider.of<SquazzleBloc>(context);
    bloc.setup();
    bloc.emitEvent(SquazzleEvent(type: SquazzleEventType.start));
  }

  @override
  Widget build(BuildContext context) {
    return BlocEventStateBuilder<SquazzleEvent, SquazzleState>(
      bloc: bloc,
      builder: (context, state) {
        switch(state.type) {
          case SquazzleStateType.error : {
            return Center(child: Text(state.message),);
          }
          case SquazzleStateType.notInit : {
            return Center(child: CircularProgressIndicator());
          }
          case SquazzleStateType.init : {
            fifthWidth = MediaQuery.of(context).size.width/5;
            tenthWidth = fifthWidth/2;
            return Stack(
              children: <Widget>[
                StreamBuilder<bool>(
                  stream: bloc.correct,
                  builder: (context, snapshot) {
                    return AnimatedOpacity(
                      opacity: opacityLevel,
                      child: Container(),
                    );
                  },
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxHeight: 3*tenthWidth, maxWidth: 3*tenthWidth),
                      margin: EdgeInsets.only(top: 50),
                      alignment: Alignment.topCenter,
                      child: targetWidget(),
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: 5*fifthWidth),
                      margin: EdgeInsets.only(bottom: 40),
                      alignment: Alignment.bottomCenter,
                      child: fieldWidget(),
                    ),
                  ],
                )
              ],
            );
          }
        }
      },
    );
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  Widget fieldWidget() {
    return StreamBuilder<GameField>(
      stream: bloc.gameField,
      initialData: field,
      builder: (context, snapshot) {
        field = snapshot.data;
        keys = List();
        _switchAnimCont = List();
        _switchAnim = List();
        _switchTween = List();
        for (int i = 0; i < 25; i++) {
          keys.add(GlobalKey(debugLabel: '$i'));
          _switchAnimCont.add(AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 100),
          ));
          _switchTween.add(Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)));
          _switchAnim.add(_switchTween[i].animate(_switchAnimCont[i]));
        }
        return Stack(
          children: <Widget>[
            // Top row
            square(0, 0, 4*fifthWidth),
            square(1, fifthWidth, 4*fifthWidth),
            square(2, 2*fifthWidth, 4*fifthWidth),
            square(3, 3*fifthWidth, 4*fifthWidth),
            square(4, 4*fifthWidth, 4*fifthWidth),
            // First row
            square(5, 0, 3*fifthWidth),
            square(6, fifthWidth, 3*fifthWidth),
            square(7, 2*fifthWidth, 3*fifthWidth),
            square(8, 3*fifthWidth, 3*fifthWidth),
            square(9, 4*fifthWidth, 3*fifthWidth),
            // Second row
            square(10, 0, 2*fifthWidth),
            square(11, fifthWidth, 2*fifthWidth),
            square(12, 2*fifthWidth, 2*fifthWidth),
            square(13, 3*fifthWidth, 2*fifthWidth),
            square(14, 4*fifthWidth, 2*fifthWidth),
            // Third row
            square(15, 0, 1*fifthWidth),
            square(16, fifthWidth, 1*fifthWidth),
            square(17, 2*fifthWidth, 1*fifthWidth),
            square(18, 3*fifthWidth, 1*fifthWidth),
            square(19, 4*fifthWidth, 1*fifthWidth),
            // Fourth row
            square(20, 0, 0),
            square(21, fifthWidth, 0),
            square(22, 2*fifthWidth, 0),
            square(23, 3*fifthWidth, 0),
            square(24, 4*fifthWidth, 0),
          ],
        );
      },
    );
  }

  Widget square(int index, double left, double bottom) {
    return Positioned(
      left: left,
      bottom: bottom,
      width: fifthWidth,
      height: fifthWidth,
      child: SlideTransition(
        position: _switchAnim[index],
        child: GestureDetector(
          key: keys[index],
          onVerticalDragUpdate: (drag) {
            if (drag.delta.dy > 10) move = 'down';
            if (drag.delta.dy < -10) move = 'up';
          },
          onHorizontalDragUpdate: (drag) {
            if (drag.delta.dx > 10) move = 'right';
            if (drag.delta.dx < -10) move = 'left';
          },
          onVerticalDragEnd: (drag) {
            print('$index: $move');
            switch(move) {
              case 'up' : {moveUp(index);break;}
              case 'down' : {moveDown(index);break;}
            }
          },
          onHorizontalDragEnd: (drag) {
            print('$index: $move');
            switch(move) {
              case 'right' : {moveRight(index); break;}
              case 'left' : {moveLeft(index); break;}
            }
          },
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors[field.grid[(index/5).truncate()][index%5]],
              borderRadius: BorderRadius.all(Radius.circular(5.0))
            ),
          ),
        ),
      ),
    );
  }

  Widget targetWidget() {
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

  void moveRight(int index) {
    if (index%5 != 4) {
      _switchTween[index].end = Offset(1, 0);
      _switchAnimCont[index].forward().then((c) {
        bloc.move.add([index, 1]);
      });
      _switchTween[index+1].end = Offset(-1, 0);
      _switchAnimCont[index+1].forward();
    }
  }

  void moveLeft(int index) {
    if (index%5 != 0) {
      _switchTween[index].end = Offset(-1, 0);
      _switchAnimCont[index].forward().then((c) {
        bloc.move.add([index, 3]);
      });
      _switchTween[index-1].end = Offset(1, 0);
      _switchAnimCont[index-1].forward();
    }
  }

  void moveUp(int index) {
    if ((index/5).truncate() != 0) {
      _switchTween[index].end = Offset(0, -1);
      _switchAnimCont[index].forward().then((c) {
        bloc.move.add([index, 0]);
      });
      _switchTween[index-5].end = Offset(0, 1);
      _switchAnimCont[index-5].forward();
    }
  }

  void moveDown(int index) {
    if ((index/5).truncate() != 4) {
      _switchTween[index].end = Offset(0, 1);
      _switchAnimCont[index].forward().then((c) {
        bloc.move.add([index, 2]);
      });
      _switchTween[index+5].end = Offset(0, -1);
      _switchAnimCont[index+5].forward();
    }
  }


  @override
  void dispose() {
    super.dispose();
    _switchAnimCont.forEach((c) => c.dispose());
  }

}