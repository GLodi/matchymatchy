import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';

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
  bool boh = false;
  String move;
  List<GlobalKey> keys = List();
  Animation _switchAnim;
  AnimationController _switchAnimCont;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 25; i++) keys.add(GlobalKey(debugLabel:'$i'));
    _switchAnimCont = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _switchAnim = new RelativeRectTween(
      begin: RelativeRect.fromLTRB(0,0, 20,0),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_switchAnimCont);

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
          case SquazzleStateType.init : { return fieldWidget(state); }
        }
      },
    );
  }

  Widget fieldWidget(SquazzleState state) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        crossAxisCount: 5,
        children: List.generate(25, (index) {
          return GestureDetector(
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
            onVerticalDragEnd: (drag) {print('$index: $move');},
            onHorizontalDragEnd: (drag) {
              RenderBox square = keys[index+1].currentContext.findRenderObject();
              final Offset nextToRightPos = square.localToGlobal(Offset.zero);
              square = keys[index].currentContext.findRenderObject();
              final Offset currPos = square.localToGlobal(Offset.zero);
              print('$index: $move');
            },
            child: Container(
              decoration: BoxDecoration(
                  color: colors[state.field.grid[(index/5).truncate()][index%5]],
                  borderRadius: BorderRadius.all(Radius.circular(5.0))
              ),
            ),
          );
        }),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _switchAnimCont.dispose();
  }

}