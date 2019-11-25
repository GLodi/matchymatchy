import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

abstract class MatchListItem {}

class ActiveMatchItem extends StatefulWidget implements MatchListItem {
  final ActiveMatch activeMatch;
  final User user;
  final bool isOnline;

  ActiveMatchItem({Key key, this.activeMatch, this.user, this.isOnline})
      : super(key: key);

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
        height: 140,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
        child: GestureDetector(
          onTap: () => widget.isOnline
              ? Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      child: MultiScreen(heroTag: widget.activeMatch.matchId),
                      bloc: kiwi.Container().resolve<MultiBloc>(),
                    ),
                  ),
                )
              : null,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 3,
            color: Colors.blue[100],
            child: activeElements(),
          ),
        ),
      ),
    );
  }

  Widget activeElements() {
    return Stack(
      children: <Widget>[
        pic(false),
        pic(true),
        centerMoves(),
        username(false),
        username(true),
      ],
    );
  }

  Widget username(bool isOnTheRight) {
    return Container(
      margin: isOnTheRight
          ? EdgeInsets.fromLTRB(0, 0, 10, 15)
          : EdgeInsets.fromLTRB(10, 0, 0, 15),
      child: Align(
        alignment: isOnTheRight ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Text(
          isOnTheRight
              ? (widget.activeMatch.isPlayerHost == 0
                  ? widget.user.username
                  : widget.activeMatch.enemyName)
              : (widget.activeMatch.isPlayerHost == 1
                  ? widget.user.username
                  : widget.activeMatch.enemyName),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget centerMoves() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.activeMatch.isPlayerHost == 1
                ? widget.activeMatch.moves.toString()
                : widget.activeMatch.enemyMoves.toString(),
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 30,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(width: 20),
          Text(
            widget.activeMatch.isPlayerHost == 0
                ? widget.activeMatch.moves.toString()
                : widget.activeMatch.enemyMoves.toString(),
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 30,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget pic(bool isOnTheRight) {
    return Align(
      alignment: isOnTheRight ? Alignment.centerRight : Alignment.centerLeft,
      child: ShaderMask(
        shaderCallback: (Rect rect) {
          return LinearGradient(
            begin: isOnTheRight ? Alignment.centerRight : Alignment.centerLeft,
            end: isOnTheRight ? Alignment.centerLeft : Alignment.centerRight,
            colors: <Color>[Colors.black, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        child: ClipRRect(
          borderRadius: isOnTheRight
              ? BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              height: 140,
              fit: BoxFit.cover,
              imageUrl: isOnTheRight
                  ? (widget.activeMatch.isPlayerHost == 0
                      ? widget.user.photoUrl
                      : widget.activeMatch.enemyUrl)
                  : (widget.activeMatch.isPlayerHost == 1
                      ? widget.user.photoUrl
                      : widget.activeMatch.enemyUrl),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        blendMode: BlendMode.dstIn,
      ),
    );
  }
}

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
      color: widget.pastMatch.moves > widget.pastMatch.enemyMoves
          ? Colors.green[100]
          : Colors.red[100],
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
