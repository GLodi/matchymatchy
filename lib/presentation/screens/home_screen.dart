import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intro_slider/intro_slider.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/presentation/widgets/row_square_widget.dart';
import 'package:squazzle/presentation/widgets/user_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeBloc bloc;
  final InfiniteScrollController _infiniteController = InfiniteScrollController(
    initialScrollOffset: 0.0,
  );
  List<Slide> slides = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => applyMovement());

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
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: InfiniteListView.builder(
            controller: _infiniteController,
            itemBuilder: (context, inte) =>
                RowSquareWidget(width: MediaQuery.of(context).size.width / 5),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Opacity(
            opacity: 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.1, 0.3, 0.5, 0.6, 0.7, 0.8, 0.9],
                  colors: [
                    Colors.red[300],
                    Colors.red[400],
                    Colors.red[500],
                    Colors.red[600],
                    Colors.red[700],
                    Colors.red[800],
                    Colors.red[900],
                  ],
                ),
              ),
            ),
          ),
        ),
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

  Widget initLogged(User user) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Stack(children: <Widget>[
      UserWidget(user: user, height: height, width: width),
      Center(
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
                "Multiplayer",
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                bloc.emitEvent(HomeEvent(type: HomeEventType.multiButtonPress));
              }),
        ],
      )),
    ]);
  }

  Widget initNotLogged() {
    return Stack(
      children: <Widget>[
        Center(
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
                    "Log in",
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    bloc.emitEvent(
                        HomeEvent(type: HomeEventType.multiButtonPress));
                  }),
            ],
          ),
        ),
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

  void applyMovement() {
    const minute = const Duration(seconds: 60);
    _infiniteController.animateTo(
      _infiniteController.offset + 2000.0,
      duration: minute,
      curve: Curves.linear,
    );
    Timer.periodic(minute, (Timer t) {
      _infiniteController.animateTo(
        _infiniteController.offset + 2000.0,
        duration: minute,
        curve: Curves.linear,
      );
    });
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
}
