import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/presentation/widgets/user_widget.dart';
import 'package:squazzle/presentation/widgets/home_matchlist_widget.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';

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
    return Stack(
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
        bottomButtons(),
      ],
    );
  }

  Widget bottomButtons() {
    // TODO: add animation to this. Opposite of user_widget
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 80,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            practiceFAB(),
            multiButton(),
          ],
        ),
      ),
    );
  }

  Widget practiceFAB() {
    return Container(
      height: 55.0,
      width: 55.0,
      margin: EdgeInsets.only(right: 20),
      child: FittedBox(
        child: FloatingActionButton(
          heroTag: 'single',
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.videogame_asset, color: Colors.blue[800], size: 35),
          elevation: 0,
          highlightElevation: 0,
          onPressed: () {
            widget.isTest
                ? openMultiScreen()
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        child: SingleScreen(),
                        bloc: kiwi.Container().resolve<SingleBloc>(),
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget multiButton() {
    return Expanded(
      child: Hero(
        tag: 'multibutton',
        child: StreamBuilder<bool>(
          initialData: false,
          stream: widget.bloc.connChange,
          builder: (context, snapshot) {
            return MaterialButton(
              height: 45,
              padding: EdgeInsets.all(10),
              color: Colors.blue[100],
              elevation: 0,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () => snapshot.data
                  ? widget.bloc.emitEvent(
                      HomeEvent(type: HomeEventType.multiButtonPress))
                  : null,
              child: Text(
                snapshot.data ? "queue for new match" : "offline",
                style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0),
              ),
            );
          },
        ),
      ),
    );
  }

  void openMultiScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          child: MultiScreen('multibutton'),
          bloc: kiwi.Container().resolve<MultiBloc>(),
        ),
      ),
    );
  }
}
