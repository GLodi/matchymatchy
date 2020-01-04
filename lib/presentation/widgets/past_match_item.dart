import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:matchymatchy/presentation/widgets/matchlist_item.dart';
import 'package:matchymatchy/presentation/screens/multi_screen.dart';
import 'matchlist_item.dart';
import 'package:matchymatchy/domain/domain.dart';
import 'package:matchymatchy/data/models/models.dart';

class PastMatchItem extends StatefulWidget implements MatchListItem {
  final PastMatch pastMatch;
  final User user;

  PastMatchItem({Key key, this.pastMatch, this.user});

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
      child: GestureDetector(
        onTap: () => _openMultiScreen(),
        child: pastElements(),
      ),
    );
  }

  Widget pastElements() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      color: widget.pastMatch.winner == null
          ? Colors.yellow[100]
          : (widget.pastMatch.moves < widget.pastMatch.enemyMoves
              ? Colors.green[100]
              : Colors.red[100]),
      child: Stack(
        children: <Widget>[
          winLostText(widget.pastMatch.moves < widget.pastMatch.enemyMoves),
          pic(true),
          pic(false),
        ],
      ),
    );
  }

  Widget winLostText(bool win) {
    return Center(
      child: Text(
        widget.pastMatch.winner == null
            ? "draw"
            : (widget.pastMatch.moves < widget.pastMatch.enemyMoves
                ? "won!"
                : "lost"),
        style: TextStyle(
          color: widget.pastMatch.winner == null
              ? Colors.yellow[800]
              : (widget.pastMatch.moves < widget.pastMatch.enemyMoves
                  ? Colors.green[800]
                  : Colors.red[800]),
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
                  ? (widget.pastMatch.isPlayerHost == 0
                      ? widget.user.photoUrl
                      : widget.pastMatch.enemyUrl)
                  : (widget.pastMatch.isPlayerHost == 1
                      ? widget.user.photoUrl
                      : widget.pastMatch.enemyUrl),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        blendMode: BlendMode.dstIn,
      ),
    );
  }

  void _openMultiScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          child: MultiScreen(heroTag: widget.pastMatch.matchId),
          bloc: kiwi.Container().resolve<MultiBloc>(),
        ),
      ),
    );
  }
}
