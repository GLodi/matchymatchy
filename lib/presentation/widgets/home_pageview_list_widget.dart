import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

class HomePageViewListWidget extends StatefulWidget {
  HomePageViewListWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageViewListWidgetState();
  }
}

class _HomePageViewListWidgetState extends State<HomePageViewListWidget> {
  HomePageViewListBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<HomePageViewListBloc>(context);
    bloc.emitEvent(HomePageViewListEvent(type: HomePageViewEventType.start));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActiveMatch>>(
      stream: bloc.activeMatches,
      initialData: [],
      builder: (context, snapshot1) {
        return StreamBuilder<List<PastMatch>>(
          stream: bloc.pastMatches,
          initialData: [],
          builder: (context2, snapshot2) {
            if (snapshot1.data.isNotEmpty || snapshot2.data.isNotEmpty)
              return init(snapshot1.data, snapshot2.data);
            else
              return notInit();
          },
        );
      },
    );
  }

  Widget init(List<ActiveMatch> activeMatches, List<PastMatch> pastMatches) {
    return ListView.builder(
      itemCount: activeMatches.length,
      itemBuilder: (context, position) {
        return Card(
          child: Text(activeMatches[position].gfid.toString(),
              style: TextStyle(color: Colors.black)),
        );
      },
    );
  }

  Widget notInit() {
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
          Text('Retrieving matches...',
              style: TextStyle(color: Colors.blue[300])),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
