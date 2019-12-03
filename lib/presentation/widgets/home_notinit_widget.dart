import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';

class HomeNotInitWidget extends StatefulWidget {
  final HomeBloc bloc;

  HomeNotInitWidget({this.bloc});

  @override
  State<StatefulWidget> createState() {
    return _HomeNotInitWidgetState();
  }
}

class _HomeNotInitWidgetState extends State<HomeNotInitWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        centerButtons(),
        StreamBuilder<bool>(
          initialData: false,
          stream: widget.bloc.showSlides,
          builder: (context, snapshot) {
            return Container();
            // return Visibility(
            //   visible: snapshot.data,
            //   replacement: Container(),
            //   maintainInteractivity: false,
            //   child: IntroSlider(
            //     slides: slides,
            //     onDonePress: () => bloc.doneSlidesButton.add(false),
            //   ),
            // );
          },
        ),
      ],
    );
  }

  Widget centerButtons() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 100),
          practiceButton(),
          SizedBox(height: 30),
          loginButton(),
        ],
      ),
    );
  }

  Widget practiceButton() {
    return Hero(
      tag: 'single',
      child: MaterialButton(
        onPressed: () => BlocProvider(
          child: SingleScreen(),
          bloc: kiwi.Container().resolve<SingleBloc>(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        highlightElevation: 2,
        color: Colors.blue[200],
        minWidth: 250,
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.videogame_asset, color: Colors.white, size: 80),
              Text(
                "practice",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return Hero(
      tag: 'multibutton',
      child: StreamBuilder<bool>(
        initialData: false,
        stream: widget.bloc.connChange,
        builder: (context, snapshot) {
          return MaterialButton(
            onPressed: () => snapshot.data
                ? widget.bloc
                    .emitEvent(HomeEvent(type: HomeEventType.multiButtonPress))
                : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 8,
            highlightElevation: 2,
            color: Colors.blue[200],
            minWidth: 250,
            child: Container(
              margin: EdgeInsets.all(20),
              child: Text(
                "login",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4.0),
              ),
            ),
          );
        },
      ),
    );
  }

  void openMultiScreen() {
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
