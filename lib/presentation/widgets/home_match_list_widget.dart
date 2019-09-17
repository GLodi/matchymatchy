import 'package:flutter/material.dart';

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
      return list();
    else
      return Center();
  }

  Widget list() {
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

  bool areListsEmpty() {
    return widget.activeMatches.isEmpty && widget.pastMatches.isEmpty;
  }
}
