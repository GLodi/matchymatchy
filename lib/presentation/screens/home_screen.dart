import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/presentation/widgets/home_notinit_widget.dart';
import 'package:squazzle/presentation/widgets/home_init_widget.dart';

class HomeScreen extends StatefulWidget {
  final bool isTest;

  HomeScreen(this.isTest);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HomeBloc>(context);
    bloc.setup();
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
                return HomeInitWidget(state.user, widget.isTest, bloc);
                break;
              case HomeStateType.initNotLogged:
                return HomeNotInitWidget(widget.isTest, bloc);
                break;
              case HomeStateType.notInit:
                return Center(
                  child: SpinKitRotatingPlain(
                    color: Colors.blue[100],
                    size: 80.0,
                  ),
                );
                break;
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
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
