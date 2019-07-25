import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/multi_game_widget.dart';
import 'package:squazzle/presentation/widgets/win_widget.dart';

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
  bool contrDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );
    statusListener = (status) async {
      try {
        await Future.delayed(Duration(seconds: 3));
        if (!contrDisposed) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
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
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
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
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: BlocEventStateBuilder<GameEvent, GameState>(
              bloc: bloc,
              builder: (context, state) {
                switch (state.type) {
                  case GameStateType.error:
                    {
                      return Center(child: Text(state.message));
                    }
                  case GameStateType.notInit:
                    {
                      return notInit();
                    }
                  case GameStateType.init:
                    {
                      return init();
                    }
                }
              },
            )),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Close match'),
            content: new Text('Do you want to exit?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget init() {
    return Stack(
      children: <Widget>[
        // AbsorbPointer is needed to prevent the player
        // from moving squares when transitioning to win_widget
        AbsorbPointer(
            absorbing: opacityLevel != 0,
            child: MultiGameWidget(
                bloc: bloc,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width)),
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

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    bloc.dispose();
    contrDisposed = true;
    _controller.dispose();
    super.dispose();
  }
}
