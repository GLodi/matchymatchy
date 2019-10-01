import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

abstract class MatchListItem {}

class ActiveMatchItem extends StatefulWidget implements MatchListItem {
  final ActiveMatch activeMatch;

  ActiveMatchItem(this.activeMatch);

  @override
  State<StatefulWidget> createState() {
    return _ActiveMatchItemState();
  }
}

class _ActiveMatchItemState extends State<ActiveMatchItem> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.activeMatch.matchId,
      child: Container(
        height: 110,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
        child: MaterialButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                child: MultiScreen(widget.activeMatch.matchId),
                bloc: kiwi.Container().resolve<MultiBloc>(),
              ),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          highlightElevation: 0,
          color: Colors.blue[100],
          child: elements(),
        ),
      ),
    );
  }

  Widget elements() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 70,
            width: 70,
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.activeMatch.enemyUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.activeMatch.enemyName.toString(),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "You",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 35, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.activeMatch.enemyMoves.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  widget.activeMatch.moves.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PastMatchItem extends StatefulWidget implements MatchListItem {
  final PastMatch pastMatch;

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
