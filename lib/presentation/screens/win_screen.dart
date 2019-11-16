import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';

class WinScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WinState();
  }
}

class _WinState extends State<WinScreen> with TickerProviderStateMixin {
  AnimationController _entryAnimCont;
  Animation<double> _entryAnim;

  WinBloc bloc;

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000), value: 0.1);
    _entryAnim = CurvedAnimation(parent: _entryAnimCont, curve: Curves.ease);
    bloc = BlocProvider.of<WinBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    _entryAnimCont.forward();
    return ScaleTransition(
      scale: _entryAnim,
      alignment: Alignment.center,
      child: BlocEventStateBuilder<WinEvent, WinState>(
        bloc: bloc,
        builder: (context, state) {
          switch (state.type) {
            case WinStateType.waitingForOpp:
              return Center(
                child: Text('waiting for opponent to end'),
              );
              break;
            case WinStateType.winnerDeclared:
              return Center(
                child: Text('winner: ' + state.winner),
              );
              break;
            default:
              return Container();
          }
        },
      ),
    );
  }
}
