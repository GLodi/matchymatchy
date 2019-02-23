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
  double fifthWidth;
  GameField field = GameField(grid: [
    [1,1,1,1,1],
    [1,1,1,1,1],
    [1,1,1,1,1],
    [1,1,1,1,1],
    [1,1,1,1,1],
  ]);

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 25; i++) {
      keys.add(GlobalKey(debugLabel: '$i'));
      _switchAnimCont.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      ));
      _switchTween.add(Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)));
      _switchAnim.add(_switchTween[i].animate(_switchAnimCont[i]));
    }

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
            fifthWidth = MediaQuery.of(context).size.width / 5;
            return fieldWidget();
          }
        }
      },
    );
  }

  Widget fieldWidget() {
    return StreamBuilder<GameField>(
      stream: bloc.gameField,
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
            duration: const Duration(milliseconds: 250),
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
          onTap: (){
            final RenderBox renderBoxRed = keys[index].currentContext.findRenderObject();
            final positionRed = renderBoxRed.localToGlobal(Offset.zero);
            print("POSITION of $index: $positionRed ");
          },
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
              case 'up' : {
                _switchTween[index].end = Offset(0, -1);
                _switchAnimCont[index].forward();
                break;
              }
              case 'down' : {
                _switchTween[index].end = Offset(0, 1);
                _switchAnimCont[index].forward();
                break;
              }
            }
          },
          onHorizontalDragEnd: (drag) {
            print('$index: $move');
            switch(move) {
              case 'right' : {
                _switchTween[index].end = Offset(1, 0);
                _switchAnimCont[index].forward();
                _switchTween[index+1].end = Offset(-1, 0);
                _switchAnimCont[index+1].forward().then((c) {
                  bloc.move.add([index, 1]);
                });
                break;
              }
              case 'left' : {
                _switchTween[index].end = Offset(-1, 0);
                _switchAnimCont[index].forward();
                _switchTween[index-1].end = Offset(1, 0);
                _switchAnimCont[index-1].forward();
                break;
              }
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

  @override
  void dispose() {
    super.dispose();
    _switchAnimCont.forEach((c) => c.dispose());
  }

}