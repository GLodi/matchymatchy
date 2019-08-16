import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';

class HomeMatchList extends StatefulWidget {
  final List<MatchOnline> matchList;
  HomeMatchList({Key key, this.matchList}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeMatchListState();
  }
}

class _HomeMatchListState extends State<HomeMatchList> {
  @override
  Widget build(BuildContext context) {
    if (widget.matchList != null)
      return list();
    else
      return Container(color: Colors.blue);
  }

  Widget list() {
    return ListView.builder(
      itemBuilder: (context, position) {
        return Card(
          child: Text(widget.matchList[position].matchId.toString()),
        );
      },
    );
  }
}
