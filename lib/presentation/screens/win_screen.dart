import 'package:flutter/material.dart';

import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/data/models/models.dart';

class WinScreen extends StatefulWidget {
  final int moves;
  final String matchId;

  WinScreen({this.moves, this.matchId});

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
    widget.matchId == null
        ? bloc.emitEvent(WinEvent.single(widget.moves))
        : bloc.emitEvent(WinEvent.multi(widget.matchId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: BlocEventStateBuilder<WinEvent, WinState>(
        bloc: bloc,
        builder: (context, state) {
          switch (state.type) {
            case WinStateType.singleWin:
              return singleWinWidget(state.moves);
              break;
            case WinStateType.waitingForOpp:
              return Center(
                child: Text('waiting for opponent to end'),
              );
              break;
            case WinStateType.winnerDeclared:
              return multiWinWidget(state.message);
              break;
            default:
              return Container();
          }
        },
      ),
    );
  }

  Widget multiWinWidget(WinnerMessage message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message.winner + " did it in",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            message.moves.toString(),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            "moves!",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget singleWinWidget(int moves) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "You did it in",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            moves.toString(),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            "moves!",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
