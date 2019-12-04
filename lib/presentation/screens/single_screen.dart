import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/presentation/widgets/game_field_widget.dart';
import 'package:matchymatchy/presentation/widgets/target_field_widget.dart';
import 'package:matchymatchy/presentation/screens/win_screen.dart';
import 'package:matchymatchy/presentation/utils/scale_route.dart';

class SingleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SingleScreenState();
}

class _SingleScreenState extends State<SingleScreen>
    with TickerProviderStateMixin {
  SingleBloc bloc;
  AnimationController _entryAnimCont;
  Animation<double> _entryAnim;
  double fifthWidth, tenthWidth;

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000), value: 0.1);
    _entryAnim = CurvedAnimation(parent: _entryAnimCont, curve: Curves.ease);
    bloc = BlocProvider.of<SingleBloc>(context);
    bloc.emitEvent(GameEvent.start());
    bloc.intentToWinScreen.listen((_) => _openWinScreen());
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
            borderRadius: BorderRadius.circular(30.0),
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
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?', style: TextStyle(color: Colors.black)),
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

  Widget initScreen() {
    _entryAnimCont.forward();
    return ScaleTransition(
      scale: _entryAnim,
      alignment: Alignment.center,
      child: Column(
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
    );
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

  Widget gfWidget() {
    return Container(
      constraints: BoxConstraints(maxHeight: 5 * fifthWidth),
      alignment: Alignment.bottomCenter,
      child: BlocProvider(
        child: GameFieldWidget(),
        bloc: GameFieldBloc(bloc),
      ),
    );
  }

  void _openWinScreen() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      ScaleRoute(
        widget: BlocProvider(
          child: WinScreen(),
          bloc: kiwi.Container().resolve<WinBloc>(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entryAnimCont.dispose();
    super.dispose();
  }
}
