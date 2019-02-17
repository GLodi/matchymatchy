import 'package:flutter/material.dart';
import 'bloc_event_state.dart';

typedef Widget AsyncBlocEventStateBuilder<BlocState>(BuildContext context, BlocState state);

class BlocEventStateBuilder<BlocEvent,BlocState> extends StatelessWidget {
  const BlocEventStateBuilder({
    Key key,
    @required this.builder,
    @required this.bloc,
  }): assert(builder != null),
        assert(bloc != null),
        super(key: key);

  final BlocEventStateBase<BlocEvent,BlocState> bloc;
  final AsyncBlocEventStateBuilder<BlocState> builder;

  @override
  Widget build(BuildContext context){
    return StreamBuilder<BlocState>(
      stream: bloc.state,
      initialData: bloc.initialState,
      builder: (BuildContext context, AsyncSnapshot<BlocState> snapshot){
        return builder(context, snapshot.data);
      },
    );
  }
}