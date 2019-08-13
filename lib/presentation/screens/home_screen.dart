import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:page_indicator/page_indicator.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<PageContainerState> _pageViewKey = GlobalKey();

  HomeBloc bloc;
  PageController controller;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HomeBloc>(context);
    bloc.setup();
    bloc.connChange.listen((connStatus) => connectionChange(connStatus));
    bloc.intentToMultiScreen.listen((_) => openMultiScreen());
    bloc.snackBar.listen((message) => showSnackBar(message));
    bloc.emitEvent(HomeEvent(type: HomeEventType.checkIfUserLogged));
    controller = PageController();
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
      Column(children: <Widget>[
        UserWidget(user: user, height: height, width: width),
        Expanded(
          child: PageIndicatorContainer(
            key: _pageViewKey,
            child: PageView(
              children: <Widget>[
                Container(color: Colors.purple),
                Container(color: Colors.green),
              ],
              controller: controller,
              reverse: false,
            ),
            align: IndicatorAlign.top,
            length: 2,
            indicatorSpace: 10.0,
            indicatorSelectorColor: Colors.blue[800],
          ),
        ),
      ]),
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
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 80,
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
          decoration: new BoxDecoration(color: Colors.white, boxShadow: [
            new BoxShadow(
              color: Colors.black,
              blurRadius: 5.0,
            ),
          ]),
          child: Row(
            children: <Widget>[
              practiceFAB(),
              multiButton(multiButtonText),
            ],
          ),
        ));
  }

  // Bottom left practice button
  Widget practiceFAB() {
    return Container(
      height: 55.0,
      width: 55.0,
      margin: EdgeInsets.only(right: 20),
      child: FittedBox(
        child: FloatingActionButton(
          heroTag: "single",
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
                            )),
                  );
          },
        ),
      ),
    );
  }

  // Bottom right multiplayer button
  Widget multiButton(String text) {
    return Expanded(
      child: Hero(
        tag: 'multi',
        child: MaterialButton(
          height: 45,
          padding: EdgeInsets.all(10),
          color: Colors.blue[100],
          elevation: 0,
          highlightElevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BlocProvider(
                      child: MultiScreen(),
                      bloc: kiwi.Container().resolve<MultiBloc>(),
                    )),
          ),
          child: Text(text,
              style: TextStyle(
                color: Colors.blue[800],
              )),
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
    controller.dispose();
    super.dispose();
  }
}
