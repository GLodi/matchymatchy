import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/single_screen.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/presentation/widgets/user_widget.dart';

class HomeScreen extends StatefulWidget {
  final bool isTest;
  HomeScreen(this.isTest);
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeBloc bloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HomeBloc>(context);
    bloc.setup();
    bloc.connChange.listen((connStatus) => connectionChange(connStatus));
    bloc.intentToMultiScreen.listen((_) => openMultiScreen());
    bloc.snackBar.listen((message) => showSnackBar(message));
    bloc.emitEvent(HomeEvent(type: HomeEventType.checkIfUserLogged));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        child: BlocEventStateBuilder<HomeEvent, HomeState>(
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
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }

  // Shows Single/Multi button and UserWidget at the bottom
  Widget initLogged(User user) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Stack(children: <Widget>[
      UserWidget(user: user, height: height, width: width),
      // TODO: add list of previous online matches
      bottomButtons("Multiplayer"),
    ]);
  }

  // Shows Single/Login buttons
  Widget initNotLogged() {
    return Stack(
      children: <Widget>[
        bottomButtons("Log in"),
        StreamBuilder<bool>(
          stream: bloc.showSlides,
          initialData: false,
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

  // Widget that includes both bottom bottons
  Widget bottomButtons(String multiButtonText) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Hero(
              tag: 'single',
              child: choiceButton("Singleplayer", true, () {
                widget.isTest
                    ? openMultiScreen()
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                  child: SingleScreen(),
                                  bloc: kiwi.Container().resolve<SingleBloc>(),
                                )),
                      );
              })),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Hero(
            tag: 'multi',
            child: choiceButton(multiButtonText, false, () {
              bloc.emitEvent(HomeEvent(type: HomeEventType.multiButtonPress));
            }),
          ),
        ),
      ],
    );
  }

  // Bottom left practice button
  Widget practiceButton() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: EdgeInsets.only(left: 25, top: 25, right: 15, bottom: 25),
        child: MaterialButton(
          padding: EdgeInsets.all(20),
          color: Colors.blue[200],
          child: Column(
            children: <Widget>[
              Text('Practice',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              Expanded(
                child: Image(
                  image: AssetImage('assets/icons/console.png'),
                ),
              ),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () {
            widget.isTest
                ? openMultiScreen()
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider(
                              child: SingleScreen(),
                              bloc: kiwi.Container().resolve<SingleBloc>(),
                            )),
                  );
          },
        ),
      ),
    );
  }

  // Bottom right multiplayer button
  Widget multiButton(String text) {
    return Container(
      margin: EdgeInsets.only(left: 15, top: 25, right: 25, bottom: 25),
      child: MaterialButton(
        padding: EdgeInsets.all(20),
        color: Colors.blue[200],
        child: Column(
          children: <Widget>[
            Text(text,
                style: TextStyle(
                  color: Colors.white,
                )),
            Expanded(
              child: Image(
                image: AssetImage('assets/icons/multiplayer.png'),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BlocProvider(
                    child: MultiScreen(),
                    bloc: kiwi.Container().resolve<MultiBloc>(),
                  )),
        ),
      ),
    );
  }

  // Single/Login/Multi button
  // Weird hack to make sure that their margins are correct
  Widget choiceButton(String text, bool isOnLeft, Function onPress) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: isOnLeft
              ? EdgeInsets.only(left: 25, top: 25, right: 15, bottom: 25)
              : EdgeInsets.only(left: 15, top: 25, right: 25, bottom: 25),
          child: MaterialButton(
            padding: EdgeInsets.all(20),
            color: Colors.blue[200],
            child: Column(
              children: <Widget>[
                Text(text,
                    style: TextStyle(
                      color: Colors.white,
                    )),
                Expanded(
                  child: Image(
                    image: AssetImage(isOnLeft
                        ? 'assets/icons/console.png'
                        : 'assets/icons/multiplayer.png'),
                  ),
                ),
              ],
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: onPress,
          ),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void openMultiScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BlocProvider(
                child: MultiScreen(),
                bloc: kiwi.Container().resolve<MultiBloc>(),
              )),
    );
  }

  void connectionChange(bool connStatus) {
    print(connStatus);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}
