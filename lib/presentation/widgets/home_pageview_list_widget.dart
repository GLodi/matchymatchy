import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'pageview_matchlist_item.dart';

class HomePageViewListWidget extends StatefulWidget {
  HomePageViewListWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageViewListWidgetState();
  }
}

class _HomePageViewListWidgetState extends State<HomePageViewListWidget>
    with AutomaticKeepAliveClientMixin<HomePageViewListWidget> {
  HomePageViewListBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<HomePageViewListBloc>(context);
    bloc.emitEvent(
        HomePageViewListEvent(type: HomePageViewListEventType.start));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocEventStateBuilder<HomePageViewListEvent, HomePageViewListState>(
      bloc: bloc,
      builder: (context, state) {
        switch (state.type) {
          case HomePageViewListStateType.init:
            return init(state.activeMatches, state.pastMatches);
            break;
          case HomePageViewListStateType.fetching:
            return fetching();
            break;
          case HomePageViewListStateType.empty:
            return empty();
            break;
          case HomePageViewListStateType.error:
            return error(state.message);
            break;
          default:
            return Container();
        }
      },
    );
  }

  Widget init(List<ActiveMatch> activeMatches, List<PastMatch> pastMatches) {
    return ListView.builder(
      itemCount: activeMatches.length + pastMatches.length,
      itemBuilder: (context, position) {
        return position < activeMatches.length
            ? ActiveMatchItem(activeMatches[position])
            : PastMatchItem(pastMatches[position - activeMatches.length]);
      },
    );
  }

  Widget fetching() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitRotatingPlain(
            color: Colors.blue[100],
            size: 60.0,
          ),
          SizedBox(height: 40),
          Text(
            'Retrieving matches...',
            style: TextStyle(color: Colors.blue[300]),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget empty() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No active nor past matches stored',
              style: TextStyle(color: Colors.blue[300]),
            ),
            SizedBox(height: 60),
          ]),
    );
  }

  Widget error(String message) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.blue[300])),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
