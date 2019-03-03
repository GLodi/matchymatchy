import 'package:flutter/material.dart';
import "dart:math";
import 'dart:ui';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:infinite_listview/infinite_listview.dart';
import 'dart:async';

import 'package:squazzle/domain/domain.dart';
import 'game_screen.dart';

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
  final InfiniteScrollController _infiniteController = InfiniteScrollController(
    initialScrollOffset: 0.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => applyMovement());
  }

  @override
  Widget build(BuildContext context) {
    fifthWidth = MediaQuery.of(context).size.width/5;
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: InfiniteListView.builder(
            controller: _infiniteController,
            itemBuilder: _buildItem,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Opacity(
            opacity: 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.1, 0.3, 0.5, 0.6, 0.7, 0.8, 0.9],
                  colors: [
                    Colors.red[300],
                    Colors.red[400],
                    Colors.red[500],
                    Colors.red[600],
                    Colors.red[700],
                    Colors.red[800],
                    Colors.red[900],
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                child: new Text("Singleplayer"),
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
              RaisedButton(
                child: new Text("Multiplayer"),
                onPressed: () {

                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void applyMovement() {
    const minute = const Duration(seconds:60);
    _infiniteController.animateTo(
      _infiniteController.offset + 2000.0,
      duration: minute,
      curve: Curves.linear,
    );
    new Timer.periodic(minute, (Timer t) {
      _infiniteController.animateTo(
        _infiniteController.offset + 2000.0,
        duration: minute,
        curve: Curves.linear,
      );
    });
  }

  Widget _buildItem(BuildContext context, int index) {
    var l = List<Widget>();
    for (int i=0; i<5; i++) {
      l.add(square(i, (i%5)*fifthWidth, (i/5).truncate()*fifthWidth));
    }
    return Row(children: l);
  }

  Widget background() {
    var l = List<Widget>();
    for (int i=0; i<60; i++) {
      l.add(square(i, (i%5)*fifthWidth, (i/5).truncate()*fifthWidth));
    }
    return Stack(children: l);
  }

  Widget square(int index, double left, double bottom) {
    return Container(
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