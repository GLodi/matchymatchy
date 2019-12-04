import 'package:flutter/material.dart';

import 'package:matchymatchy/data/models/models.dart';
import 'package:matchymatchy/domain/domain.dart';

const colors = {
  0: Colors.white,
  1: Colors.blue,
  2: Colors.orange,
  3: Colors.yellow,
  4: Colors.green,
  5: Colors.red,
};

class GameFieldWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GameFieldWidgetState();
  }
}

class _GameFieldWidgetState extends State<GameFieldWidget>
    with TickerProviderStateMixin {
  GameFieldBloc bloc;
  List<GlobalKey> keys = List();
  List<Tween> _switchTween = List();
  List<Animation> _switchAnim = List();
  List<AnimationController> _switchAnimCont = List();
  double fifthWidth;
  String move;
  GameField field = GameField(grid: "0000000000000000000000000");

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 25; i++) keys.add(GlobalKey(debugLabel: '$i'));
    bloc = BlocProvider.of<GameFieldBloc>(context);
    bloc.setup();
    bloc.emitEvent(WidgetEvent.start());
  }

  @override
  Widget build(BuildContext context) {
    fifthWidth = MediaQuery.of(context).size.width / 5;
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
          _switchTween
              .add(Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)));
          _switchAnim.add(_switchTween[i].animate(_switchAnimCont[i]));
        }
        return Stack(
          children: <Widget>[
            // Central frame
            frame(),
            // Top row
            square(0, 0, 4 * fifthWidth),
            square(1, fifthWidth, 4 * fifthWidth),
            square(2, 2 * fifthWidth, 4 * fifthWidth),
            square(3, 3 * fifthWidth, 4 * fifthWidth),
            square(4, 4 * fifthWidth, 4 * fifthWidth),
            // First row
            square(5, 0, 3 * fifthWidth),
            square(6, fifthWidth, 3 * fifthWidth),
            square(7, 2 * fifthWidth, 3 * fifthWidth),
            square(8, 3 * fifthWidth, 3 * fifthWidth),
            square(9, 4 * fifthWidth, 3 * fifthWidth),
            // Second row
            square(10, 0, 2 * fifthWidth),
            square(11, fifthWidth, 2 * fifthWidth),
            square(12, 2 * fifthWidth, 2 * fifthWidth),
            square(13, 3 * fifthWidth, 2 * fifthWidth),
            square(14, 4 * fifthWidth, 2 * fifthWidth),
            // Third row
            square(15, 0, 1 * fifthWidth),
            square(16, fifthWidth, 1 * fifthWidth),
            square(17, 2 * fifthWidth, 1 * fifthWidth),
            square(18, 3 * fifthWidth, 1 * fifthWidth),
            square(19, 4 * fifthWidth, 1 * fifthWidth),
            // Fourth row
            square(20, 0, 0),
            square(21, fifthWidth, 0),
            square(22, 2 * fifthWidth, 0),
            square(23, 3 * fifthWidth, 0),
            square(24, 4 * fifthWidth, 0),
          ],
        );
      },
    );
  }

  Widget frame() {
    return Center(
      child: Container(
        height: fifthWidth * 3,
        width: fifthWidth * 3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0),
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
        ),
      ),
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
            switch (move) {
              case 'up':
                {
                  moveUp(index);
                  break;
                }
              case 'down':
                {
                  moveDown(index);
                  break;
                }
            }
          },
          onHorizontalDragEnd: (drag) {
            print('$index: $move');
            switch (move) {
              case 'right':
                {
                  moveRight(index);
                  break;
                }
              case 'left':
                {
                  moveLeft(index);
                  break;
                }
            }
          },
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: colors[int.parse(field.grid[index])],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
        ),
      ),
    );
  }

  void moveRight(int index) {
    if (index % 5 != 4) {
      _switchTween[index].end = Offset(1, 0);
      _switchAnimCont[index].forward();
      _switchTween[index + 1].end = Offset(-1, 0);
      _switchAnimCont[index + 1].forward().then((c) {
        bloc.move.add([index, 1]);
      });
    }
  }

  void moveLeft(int index) {
    if (index % 5 != 0) {
      _switchTween[index].end = Offset(-1, 0);
      _switchAnimCont[index].forward();
      _switchTween[index - 1].end = Offset(1, 0);
      _switchAnimCont[index - 1].forward().then((c) {
        bloc.move.add([index, 3]);
      });
    }
  }

  void moveUp(int index) {
    if ((index / 5).truncate() != 0) {
      _switchTween[index].end = Offset(0, -1);
      _switchAnimCont[index].forward();
      _switchTween[index - 5].end = Offset(0, 1);
      _switchAnimCont[index - 5].forward().then((c) {
        bloc.move.add([index, 0]);
      });
    }
  }

  void moveDown(int index) {
    if ((index / 5).truncate() != 4) {
      _switchTween[index].end = Offset(0, 1);
      _switchAnimCont[index].forward();
      _switchTween[index + 5].end = Offset(0, -1);
      _switchAnimCont[index + 5].forward().then((c) {
        bloc.move.add([index, 2]);
      });
    }
  }

  @override
  void dispose() {
    _switchAnimCont.forEach((c) => c.dispose());
    super.dispose();
  }
}
