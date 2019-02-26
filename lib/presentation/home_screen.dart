import 'package:flutter/material.dart';
import "dart:math";
import 'dart:ui';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'game_screen.dart';
import 'package:squazzle/domain/domain.dart';


const colors2 = {
  0:Colors.white,
  1:Colors.blue,
  2:Colors.orange,
  3:Colors.yellow,
  4:Colors.green,
  5:Colors.red,
};

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _random = Random();
  double opacityLevel = 0;
  double fifthWidth;

  @override
  Widget build(BuildContext context) {
    fifthWidth = MediaQuery.of(context).size.width/5;
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          alignment: Alignment.bottomCenter,
          child: background(),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Opacity(
            opacity: 0.1,
            child: Container(
              color: Colors.black,
            ),
          ),
        ),
        Center(
          child: RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    body: BlocProvider(
                      child: GameScreen(),
                      bloc: kiwi.Container().resolve<SquazzleBloc>(),
                    )
                  );}
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget background() {
    var l = List<Widget>();
    for (int i=0; i<60; i++) {
      l.add(square(i, (i%5)*fifthWidth, (i/5).truncate()*fifthWidth));
    }
    return Stack(children: l);
  }

  Widget square(int index, double left, double bottom) {
    return Positioned(
      left: left,
      bottom: bottom,
      width: fifthWidth,
      height: fifthWidth,
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors2[_random.nextInt(colors2.length)],
          borderRadius: BorderRadius.all(Radius.circular(5.0))
        ),
      ),
    );
  }
}