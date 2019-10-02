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
  _MultiGameWidgetState createState() => _MultiGameWidgetState();
}

class _MultiGameWidgetState extends State<MultiGameWidget>
    with TickerProviderStateMixin {
  AnimationController _entryAnimCont;
  Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000), value: 0.1);
    _entryAnim = CurvedAnimation(parent: _entryAnimCont, curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    double tenthWidth = widget.width / 10;
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 3 * tenthWidth,
                            maxWidth: 3 * tenthWidth,
                          ),
                          alignment: Alignment.topCenter,
                          child: BlocProvider(
                            child: EnemyWidget(),
                            bloc: EnemyFieldBloc(widget.bloc),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Opponent", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    StreamBuilder<int>(
                      stream: widget.bloc.moveNumber,
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
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: 3 * tenthWidth,
                            maxWidth: 3 * tenthWidth,
                          ),
                          alignment: Alignment.topCenter,
                          child: BlocProvider(
                            child: TargetFieldWidget(),
                            bloc: TargetBloc(widget.bloc),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Target", style: TextStyle(fontSize: 15)),
                      ],
                    )
                  ],
                ),
                SafeArea(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: widget.width),
                    alignment: Alignment.bottomCenter,
                    child: BlocProvider(
                      child: GameFieldWidget(),
                      bloc: GameFieldBloc(widget.bloc),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
