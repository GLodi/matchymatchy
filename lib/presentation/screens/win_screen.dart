import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';

class WinScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WinState();
  }
}

class _WinState extends State<WinScreen> {
  WinBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<WinBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: 1,
      child: Visibility(
        visible: true,
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
      ),
    );
  }
}
