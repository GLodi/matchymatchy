import 'package:flutter/material.dart';

import 'package:squazzle/data/models/models.dart';

abstract class MatchListItem {}

class ActiveMatchItem extends StatefulWidget implements MatchListItem {
  ActiveMatch activeMatch;

  ActiveMatchItem(this.activeMatch);

  @override
  State<StatefulWidget> createState() {
    return _ActiveMatchItemState();
  }
}

class _ActiveMatchItemState extends State<ActiveMatchItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text('active' + widget.activeMatch.gfid.toString(),
          style: TextStyle(color: Colors.black)),
    );
  }
}

class PastMatchItem extends StatefulWidget implements MatchListItem {
  PastMatch pastMatch;

  PastMatchItem(this.pastMatch);

  @override
  State<StatefulWidget> createState() {
    return _PastMatchItemState();
  }
}

class _PastMatchItemState extends State<PastMatchItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text('past' + widget.pastMatch.moves.toString(),
          style: TextStyle(color: Colors.black)),
    );
  }
}
