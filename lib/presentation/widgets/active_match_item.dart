import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'matchlist_item.dart';

class ActiveMatchItem extends StatefulWidget implements MatchListItem {
  final ActiveMatch activeMatch;
  final User user;

  ActiveMatchItem({this.activeMatch, this.user});

  @override
  State<StatefulWidget> createState() {
    return _ActiveMatchItemState();
  }
}

class _ActiveMatchItemState extends State<ActiveMatchItem> {
  ActiveMatchItemBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ActiveMatchItemBloc>(context);
    bloc.setup();
    bloc.intentToMultiScreen.listen((_) => _openMultiScreen());
    bloc.emitEvent(ActiveItemEvent.start(widget.activeMatch.matchId));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.activeMatch.matchId,
      child: Container(
        height: 140,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
        child: GestureDetector(
          onTap: () => bloc.onItemPress.add(true),
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
        child: Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              isOnTheRight
                  ? (widget.activeMatch.isPlayerHost == 0
                      ? widget.user.username
                      : widget.activeMatch.enemyName)
                  : (widget.activeMatch.isPlayerHost == 1
                      ? widget.user.username
                      : widget.activeMatch.enemyName),
              style: TextStyle(
                fontSize: 15,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black,
              ),
            ),
            // Solid text as fill.
            Text(
              isOnTheRight
                  ? (widget.activeMatch.isPlayerHost == 0
                      ? widget.user.username
                      : widget.activeMatch.enemyName)
                  : (widget.activeMatch.isPlayerHost == 1
                      ? widget.user.username
                      : widget.activeMatch.enemyName),
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget centerMoves() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder<int>(
              initialData: 0,
              stream: bloc.enemyMove,
              builder: (contet, snapshot) {
                return Text(
                  widget.activeMatch.isPlayerHost == 1
                      ? widget.activeMatch.moves.toString()
                      : snapshot.data.toString(),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                  ),
                );
              }),
          SizedBox(width: 20),
          StreamBuilder<int>(
              initialData: 0,
              stream: bloc.enemyMove,
              builder: (contet, snapshot) {
                return Text(
                  widget.activeMatch.isPlayerHost == 0
                      ? widget.activeMatch.moves.toString()
                      : snapshot.data.toString(),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                  ),
                );
              }),
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

  void _openMultiScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          child: MultiScreen(heroTag: widget.activeMatch.matchId),
          bloc: kiwi.Container().resolve<MultiBloc>(),
        ),
      ),
    );
  }
}
