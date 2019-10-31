import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/multi_game_widget.dart';
import 'package:squazzle/presentation/widgets/win_widget.dart';

class MultiScreen extends StatefulWidget {
  final String heroTag;

  MultiScreen(this.heroTag);

  @override
  _MultiScreenState createState() => _MultiScreenState();
}

class _MultiScreenState extends State<MultiScreen>
    with TickerProviderStateMixin {
  MultiBloc bloc;
  double opacityLevel = 0;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MultiBloc>(context);
    bloc.setup();
    widget.heroTag == 'multibutton'
        ? bloc.emitEvent(GameEvent(type: GameEventType.queue))
        : bloc.emitEvent(GameEvent(
            type: GameEventType.connect, connectMatchId: widget.heroTag));
    bloc.correct.listen((correct) => _changeOpacity());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'multiplayer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            initialData: false,
            stream: bloc.hasMatchStarted,
            builder: (context, snapshot) => snapshot.data
                ? IconButton(
                    icon: Icon(Icons.remove_circle),
                    tooltip: 'Forfeit match',
                    onPressed: _onForfeitButton,
                  )
                : Container(),
          ),
        ],
      ),
      body: Hero(
        tag: widget.heroTag,
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
            borderRadius: BorderRadius.circular(30.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[200],
              ),
            ),
          );
        },
        child: WillPopScope(
            onWillPop: _onBackButton,
            child: BlocEventStateBuilder<GameEvent, GameState>(
              bloc: bloc,
              builder: (context, state) {
                switch (state.type) {
                  case GameStateType.error:
                    {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    }
                  case GameStateType.notInit:
                    {
                      return notInit();
                    }
                  case GameStateType.init:
                    {
                      return init();
                    }
                  default:
                    return Container();
                }
              },
            )),
      ),
    );
  }

  Widget init() {
    return Stack(
      children: <Widget>[
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
            child: BlocProvider(
              child: WinWidget(),
              bloc: kiwi.Container().resolve<WinBloc>(),
            ),
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
          SpinKitRotatingPlain(
            color: Colors.white,
            size: 80.0,
          ),
          SizedBox(height: 80),
          StreamBuilder<String>(
            initialData: 'connecting to server...',
            stream: bloc.waitMessage,
            builder: (context, snapshot) => Text(
              snapshot.data,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  Future<bool> _onForfeitButton() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Forfeit match', style: TextStyle(color: Colors.black)),
            content: Text('Are you sure you want to forfeit the match?',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  bloc.forfeitButton.add(true);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _onBackButton() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Close match', style: TextStyle(color: Colors.black)),
            content: Text('Do you want to close match?',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
