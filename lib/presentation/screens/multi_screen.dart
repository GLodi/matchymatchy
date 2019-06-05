import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/multi_game_widget.dart';
import 'package:squazzle/presentation/widgets/win_widget.dart';
import 'package:squazzle/presentation/widgets/gradient_animation.dart';

class MultiScreen extends StatefulWidget {
  @override
  _MultiScreenState createState() => _MultiScreenState();
}

class _MultiScreenState extends State<MultiScreen>
    with TickerProviderStateMixin {
  MultiBloc bloc;
  AnimationController _controller;
  AnimationStatusListener statusListener;
  double opacityLevel = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );
    statusListener = (status) async {
      try {
        if (status == AnimationStatus.completed) {
          await Future.delayed(Duration(seconds: 3));
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          await Future.delayed(Duration(seconds: 3));
          _controller.forward();
        }
      } on TickerCanceled {}
    };
    _controller.addStatusListener(statusListener);
    _controller.forward();
    bloc = BlocProvider.of<MultiBloc>(context);
    bloc.emitEvent(GameEvent(type: GameEventType.queue));
    bloc.correct.listen((correct) => _changeOpacity());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'multi',
        // This is to prevent a Hero animation workflow
        // https://github.com/flutter/flutter/issues/27320
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
          );
        },
        child: Stack(
          children: <Widget>[
            background(),
            BlocEventStateBuilder<GameEvent, GameState>(
              bloc: bloc,
              builder: (context, state) {
                switch (state.type) {
                  case GameStateType.error:
                    {
                      print('DEBUG: error');
                      return Center(child: Text(state.message));
                    }
                  case GameStateType.notInit:
                    {
                      print('DEBUG:notInit');
                      return notInit();
                    }
                  case GameStateType.init:
                    {
                      print('DEBUG:init');
                      return init();
                    }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget init() {
    return Stack(
      children: <Widget>[
        MultiGameWidget(
            bloc: bloc,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width),
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: opacityLevel,
          child: Visibility(
            visible: opacityLevel != 0,
            child: WinWidget(),
          ),
        ),
      ],
    );
  }

  Widget notInit() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          StreamBuilder<String>(
            initialData: 'Connecting to server...',
            stream: bloc.waitMessage,
            builder: (context, snapshot) => Text(snapshot.data),
          ),
        ],
      ),
    );
  }

  Widget background() {
    return GradientAnimation(
      begin: LinearGradient(
        colors: [Colors.tealAccent, Colors.lightBlue],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      end: LinearGradient(
        colors: [Colors.pink, Colors.redAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      height: MediaQuery.of(context).size.height,
      controller: _controller,
    );
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    bloc.dispose();
    _controller.dispose();
    super.dispose();
  }
}
