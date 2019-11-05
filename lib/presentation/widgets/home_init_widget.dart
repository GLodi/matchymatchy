import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/presentation/widgets/user_widget.dart';
import 'package:squazzle/presentation/widgets/home_matchlist_widget.dart';
import 'package:squazzle/presentation/widgets/home_bottombar_widget.dart';

class HomeInitWidget extends StatefulWidget {
  final User user;
  final bool isTest;
  final HomeBloc bloc;

  HomeInitWidget(this.user, this.isTest, this.bloc);

  @override
  State<StatefulWidget> createState() {
    return _HomeInitWidgetState();
  }
}

class _HomeInitWidgetState extends State<HomeInitWidget> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _onSelected,
              itemBuilder: (context) {
                return PopMenuButton<String>();
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              StreamBuilder<User>(
                initialData: widget.user,
                stream: widget.bloc.user,
                builder: (context, snapshot) {
                  return UserWidget(
                      user: snapshot.data,
                      parentHeight: height,
                      parentWidth: width);
                },
              ),
              BlocProvider(
                child: HomeMatchListWidget(),
                bloc: kiwi.Container().resolve<HomeMatchListBloc>(),
              ),
              SizedBox(height: 80),
            ],
          ),
          HomeBottomBarWidget(
              bloc: widget.bloc, isTest: widget.isTest, parentHeight: height),
        ],
      ),
    );
  }

  void _onSelected() {}
}
