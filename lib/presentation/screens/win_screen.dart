import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';

class WinScreen extends StatefulWidget {
  final String heroTag;
  final String matchId;

  WinScreen({this.heroTag, this.matchId});

  @override
  State<StatefulWidget> createState() {
    return _WinState();
  }
}

class _WinState extends State<WinScreen> with TickerProviderStateMixin {
  WinBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<WinBloc>(context);
    bloc.emitEvent(WinEvent(type: WinEventType.start));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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
                color: Colors.green[200],
              ),
            ),
          );
        },
        child: BlocEventStateBuilder<WinEvent, WinState>(
          bloc: bloc,
          builder: (context, state) {
            switch (state.type) {
              case WinStateType.waitingForOpp:
                return Center(
                  child: Text(
                    'waiting for opponent to end',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
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
