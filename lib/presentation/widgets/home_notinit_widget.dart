import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';

class HomeNotInitWidget extends StatefulWidget {
  final bool isTest;
  final HomeBloc bloc;

  HomeNotInitWidget(this.isTest, this.bloc);

  @override
  State<StatefulWidget> createState() {
    return _HomeNotInitWidgetState();
  }
}

class _HomeNotInitWidgetState extends State<HomeNotInitWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[200]),
      child: Stack(
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
      ),
    );
  }

  Widget centerButtons() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          practiceButton(),
          loginButton(),
        ],
      ),
    );
  }

  Widget practiceButton() {
    return Hero(
      tag: 'single',
      child: MaterialButton(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        highlightElevation: 2,
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.videogame_asset, color: Colors.blue[800], size: 50),
              SizedBox(height: 10),
              Text("Practice"),
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
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.people, color: Colors.blue[800], size: 50),
                  SizedBox(height: 10),
                  Text("Login"),
                ],
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
          child: MultiScreen('multibutton'),
          bloc: kiwi.Container().resolve<MultiBloc>(),
        ),
      ),
    );
  }
}
