import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/game_field_widget.dart';
import 'package:squazzle/presentation/widgets/target_field_widget.dart';
import 'package:squazzle/presentation/widgets/enemy_field_widget.dart';

class MultiGameWidget extends StatefulWidget {
  final MultiBloc bloc;
  final double height;
  final double width;

  MultiGameWidget({this.bloc, this.height, this.width});

  @override
  _MultiGameWidgetState createState() =>
      _MultiGameWidgetState(bloc: bloc, height: height, width: width);
}

// TODO bring opacity layer to multi_screen and create new win gamestate there
class _MultiGameWidgetState extends State<MultiGameWidget>
    with TickerProviderStateMixin {
  final MultiBloc bloc;
  final double height;
  final double width;
  AnimationController _entryAnimCont;
  Animation _entryAnim;
  double opacityLevel = 0;

  _MultiGameWidgetState({this.bloc, this.height, this.width});

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _entryAnim = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: _entryAnimCont,
      curve: Curves.bounceOut,
    ));
    bloc.correct.listen((correct) => _changeOpacity());
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  Widget build(BuildContext context) {
    double tenthWidth = width / 10;
    double fifthWidth = width / 5;
    _entryAnimCont.forward();
    return AnimatedBuilder(
      animation: _entryAnimCont,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.translationValues(0, _entryAnim.value * height, 0),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 3 * tenthWidth,
                            maxWidth: 3 * tenthWidth,
                          ),
                          alignment: Alignment.topCenter,
                          child: BlocProvider(
                            child: EnemyWidget(),
                            bloc: EnemyFieldBloc(bloc),
                          ),
                        ),
                        StreamBuilder<int>(
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
                                  ),
                                ),
                                Text(
                                  snapshot.data.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 25.0,
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 3 * tenthWidth,
                            maxWidth: 3 * tenthWidth,
                          ),
                          alignment: Alignment.topCenter,
                          child: BlocProvider(
                            child: TargetFieldWidget(),
                            bloc: TargetBloc(bloc),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxHeight: 5 * fifthWidth),
                    margin: EdgeInsets.only(bottom: 40),
                    alignment: Alignment.bottomCenter,
                    child: BlocProvider(
                      child: GameFieldWidget(),
                      bloc: GameFieldBloc(bloc),
                    ),
                  ),
                ],
              ),
              AnimatedOpacity(
                duration: Duration(seconds: 2),
                opacity: opacityLevel,
                child: Visibility(
                  visible: opacityLevel != 0,
                  child: Container(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
