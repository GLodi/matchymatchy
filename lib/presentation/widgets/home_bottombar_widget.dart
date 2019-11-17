import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';

class HomeBottomBarWidget extends StatefulWidget {
  final HomeBloc bloc;
  final bool isTest;
  final double parentHeight;

  HomeBottomBarWidget({this.bloc, this.isTest, this.parentHeight});

  @override
  State<StatefulWidget> createState() {
    return _HomeBottomBarWidgetState();
  }
}

class _HomeBottomBarWidgetState extends State<HomeBottomBarWidget>
    with TickerProviderStateMixin {
  AnimationController _entryAnimCont;
  Animation _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3000));
    _entryAnim = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _entryAnimCont,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    _entryAnimCont.forward();
    return AnimatedBuilder(
        animation: _entryAnimCont,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.translationValues(
                0, _entryAnim.value * widget.parentHeight, 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                margin: EdgeInsets.only(top: 10),
                padding:
                    EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
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
            ),
          );
        });
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
                ? _openMultiScreen()
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

  void _openMultiScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          child: MultiScreen(heroTag: 'multibutton'),
          bloc: kiwi.Container().resolve<MultiBloc>(),
        ),
      ),
    );
  }
}
