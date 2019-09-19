import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:squazzle/data/models/models.dart';

class HomeMatchList extends StatefulWidget {
  final List<ActiveMatch> activeMatches;
  final List<PastMatch> pastMatches;

  HomeMatchList({Key key, this.activeMatches, this.pastMatches})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeMatchListState();
  }
}

class _HomeMatchListState extends State<HomeMatchList> {
  @override
  Widget build(BuildContext context) {
    if (!areListsEmpty())
      return init();
    else
      return notInit();
  }

  Widget init() {
    return ListView.builder(
      itemCount: widget.activeMatches.length,
      itemBuilder: (context, position) {
        return Card(
          child: Text(widget.activeMatches[position].gfid.toString(),
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

  bool areListsEmpty() {
    return widget.activeMatches.isEmpty && widget.pastMatches.isEmpty;
  }
}
