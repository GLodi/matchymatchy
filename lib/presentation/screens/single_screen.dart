import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/win_widget.dart';
import 'package:squazzle/presentation/widgets/game_field_widget.dart';
import 'package:squazzle/presentation/widgets/target_field_widget.dart';

class SingleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SingleScreenState();
}

class _SingleScreenState extends State<SingleScreen>
    with TickerProviderStateMixin {
  SingleBloc bloc;
  AnimationController _entryAnimCont;
  Animation<double> _entryAnim;
  double fifthWidth, tenthWidth, opacityLevel = 0;

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000), value: 0.1);
    _entryAnim = CurvedAnimation(parent: _entryAnimCont, curve: Curves.ease);
    bloc = BlocProvider.of<SingleBloc>(context);
    bloc.emitEvent(GameEvent(type: GameEventType.start));
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
      ),
      body: Hero(
        tag: 'single',
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
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[200],
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
                      return Center(child: CircularProgressIndicator());
                    }
                  case GameStateType.init:
                    {
                      if (fifthWidth == null && tenthWidth == null) {
                        fifthWidth = MediaQuery.of(context).size.width / 5;
                        tenthWidth = fifthWidth / 2;
                      }
                      return initScreen();
                    }
                  default:
                    return Container();
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
            title: new Text('Are you sure?'),
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

  Widget initScreen() {
    _entryAnimCont.forward();
    return ScaleTransition(
        scale: _entryAnim,
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    moves(),
                    targetField(),
                  ],
                ),
                gfWidget(),
              ],
            ),
            endOpacity(),
          ],
        ));
  }

  Widget moves() {
    return StreamBuilder<int>(
      stream: bloc.moveNumber,
      initialData: 0,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Text(
              'Moves',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            Text(
              snapshot.data.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 25.0,
                color: Colors.white,
              ),
            )
          ],
        );
      },
    );
  }

  Widget targetField() {
    return Container(
      constraints:
          BoxConstraints(maxHeight: 3 * tenthWidth, maxWidth: 3 * tenthWidth),
      alignment: Alignment.topCenter,
      child: BlocProvider(
        child: TargetFieldWidget(),
        bloc: TargetBloc(bloc),
      ),
    );
  }

  Widget endOpacity() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 5000),
      opacity: opacityLevel,
      child: Visibility(
        visible: opacityLevel != 0,
        child: WinWidget(),
      ),
    );
  }

  Widget gfWidget() {
    return Container(
      constraints: BoxConstraints(maxHeight: 5 * fifthWidth),
      alignment: Alignment.bottomCenter,
      // TODO: move field state to absordwidget
      child: AbsorbPointer(
          absorbing: opacityLevel != 0,
          child: BlocProvider(
            child: GameFieldWidget(),
            bloc: GameFieldBloc(bloc),
          )),
    );
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    _entryAnimCont.dispose();
    bloc.dispose();
    super.dispose();
  }
}
