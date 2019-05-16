import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:intro_slider/intro_slider.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/presentation/widgets/user_widget.dart';
import 'package:squazzle/presentation/widgets/gradient_animation.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeBloc bloc;
  List<Slide> slides = List();
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(Duration(seconds: 3));
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        await Future.delayed(Duration(seconds: 3));
        _controller.forward();
      }
    });

    slides.add(
      Slide(
        title: "ERASER",
        description:
            "Allow miles wound place the leave had. To sitting subject no improve studied limited",
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      Slide(
        title: "PENCIL",
        description:
            "Ye indulgence unreserved connection alteration appearance",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      Slide(
        title: "RULER",
        description:
            "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
        backgroundColor: Color(0xff9932CC),
      ),
    );

    bloc = BlocProvider.of<HomeBloc>(context);
    bloc.setup();
    bloc.intentToMultiScreen.listen((_) => openMultiScreen());
    bloc.emitEvent(HomeEvent(type: HomeEventType.checkIfUserLogged));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        background(),
        BlocEventStateBuilder<HomeEvent, HomeState>(
          bloc: bloc,
          builder: (context, state) {
            switch (state.type) {
              case HomeStateType.initLogged:
                return initLogged(state.user);
                break;
              case HomeStateType.initNotLogged:
                return initNotLogged();
                break;
              case HomeStateType.notInit:
                return Center(child: CircularProgressIndicator());
                break;
              case HomeStateType.error:
                return Center(child: Text('${state.message}'));
                break;
              default:
            }
          },
        ),
      ],
    );
  }

  Widget background() {
    return GradientAnimation(
      begin: LinearGradient(
        colors: [Colors.tealAccent, Colors.lightBlue],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      end: LinearGradient(
        colors: [Colors.pink, Colors.redAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      height: MediaQuery.of(context).size.height,
      controller: _controller,
    );
  }

  Widget initLogged(User user) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Stack(children: <Widget>[
      // TODO refresh at end of game
      UserWidget(user: user, height: height, width: width),
      buttons("Multiplayer"),
    ]);
  }

  Widget initNotLogged() {
    return Stack(
      children: <Widget>[
        buttons("Log in"),
        StreamBuilder<bool>(
          stream: bloc.showSlides,
          initialData: false,
          builder: (context, snapshot) {
            return Visibility(
              visible: snapshot.data,
              replacement: Container(),
              maintainInteractivity: false,
              child: IntroSlider(
                slides: slides,
                onDonePress: () => bloc.doneSlidesButton.add(false),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buttons(String multiButton) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RaisedButton(
          child: Text("Singleplayer"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return Scaffold(
                    body: BlocProvider(
                  child: SingleScreen(),
                  bloc: kiwi.Container().resolve<SingleBloc>(),
                ));
              }),
            );
          },
        ),
        RaisedButton(
            child: Text(
              multiButton,
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              bloc.emitEvent(HomeEvent(type: HomeEventType.multiButtonPress));
            }),
      ],
    ));
  }

  void openMultiScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return Scaffold(
            body: BlocProvider(
          child: MultiScreen(),
          bloc: kiwi.Container().resolve<MultiBloc>(),
        ));
      }),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}
