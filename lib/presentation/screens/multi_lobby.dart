import 'package:flutter/material.dart';

import 'package:squazzle/domain/domain.dart';

class MultiLobby extends StatefulWidget {
  @override
  _MultiLobbyState createState() => _MultiLobbyState();
}

class _MultiLobbyState extends State<MultiLobby> {
  MultiLobbyBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MultiLobbyBloc>(context);
    bloc.emitEvent(SquazzleEvent(type: SquazzleEventType.start));
  }

  @override
  Widget build(BuildContext context) {

  }
}