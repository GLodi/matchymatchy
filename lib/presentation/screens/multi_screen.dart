import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/multi_game_widget.dart';

class MultiScreen extends StatefulWidget {
  @override
  _MultiScreenState createState() => _MultiScreenState();
}

class _MultiScreenState extends State<MultiScreen>
    with TickerProviderStateMixin {
  MultiBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MultiBloc>(context);
    bloc.emitEvent(GameEvent(type: GameEventType.queue));
  }

  @override
  Widget build(BuildContext context) {
    return BlocEventStateBuilder<GameEvent, GameState>(
      bloc: bloc,
      builder: (context, state) {
        switch (state.type) {
          case GameStateType.error:
            {
              return Center(child: Text(state.message));
            }
          case GameStateType.notInit:
            {
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
                      builder: (context, snapshot) {
                        return Text(snapshot.data);
                      },
                    ),
                  ],
                ),
              );
            }
          case GameStateType.init:
            {
              return MultiGameWidget(
                  bloc: bloc,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width);
            }
        }
      },
    );
  }
}
