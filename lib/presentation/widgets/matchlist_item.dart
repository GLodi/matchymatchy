import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';

abstract class MatchListItem {}

class PastMatchItem extends StatefulWidget implements MatchListItem {
  final PastMatch pastMatch;
  final User user;

  PastMatchItem({Key key, this.pastMatch, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PastMatchItemState();
  }
}

class _PastMatchItemState extends State<PastMatchItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: pastElements(),
    );
  }

  Widget pastElements() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      color: widget.pastMatch.isTie == 1
          ? Colors.blue[100]
          : (widget.pastMatch.moves > widget.pastMatch.enemyMoves
              ? Colors.green[100]
              : Colors.red[100]),
      child: Stack(
        children: <Widget>[
          winLostText(widget.pastMatch.moves > widget.pastMatch.enemyMoves),
          leftImage(),
          rightImage(),
        ],
      ),
    );
  }

  Widget winLostText(bool win) {
    return Center(
      child: Text(
        win ? "won!" : "lost",
        style: TextStyle(
          color: win ? Colors.green[800] : Colors.red[800],
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget leftImage() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.user.photoUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget rightImage() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.pastMatch.enemyUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
