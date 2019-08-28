import 'package:flutter/material.dart';

import 'package:squazzle/data/models/models.dart';

class HomeMatchList extends StatefulWidget {
  final List<PastMatch> pastMatches;
  HomeMatchList({Key key, this.pastMatches}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeMatchListState();
  }
}

class _HomeMatchListState extends State<HomeMatchList> {
  @override
  Widget build(BuildContext context) {
    if (widget.pastMatches != null && widget.pastMatches.isNotEmpty)
      return list();
    else
      return Container(color: Colors.blue);
  }

  Widget list() {
    return ListView.builder(
      itemCount: widget.pastMatches.length,
      itemBuilder: (context, position) {
        return Card(
          child: Text(widget.pastMatches[position].moves.toString()),
        );
      },
    );
  }
}
