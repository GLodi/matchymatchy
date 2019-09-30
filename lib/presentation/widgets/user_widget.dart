import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';
import 'curve_painter.dart';

class UserWidget extends StatefulWidget {
  final User user;
  final double parentHeight;
  final double parentWidth;

  UserWidget({Key key, this.user, this.parentHeight, this.parentWidth})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserWidgetState();
  }
}

class _UserWidgetState extends State<UserWidget> with TickerProviderStateMixin {
  AnimationController _entryAnimCont;
  Animation _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryAnimCont = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _entryAnim = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _entryAnimCont,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    _entryAnimCont.forward();
    return AnimatedBuilder(
        animation: _entryAnimCont,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.translationValues(
                0, -_entryAnim.value * widget.parentHeight, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(20.0),
                    bottomRight: const Radius.circular(20.0),
                  ),
                ),
                child: CustomPaint(
                  painter: CurvePainter(),
                  child: elements(),
                ),
              ),
            ),
          );
        });
  }

  Widget elements() {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 120, 0),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.user.photoUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
        Positioned(
            top: 80,
            right: widget.parentWidth / 4,
            child: Column(children: [
              Text(widget.user.username, textAlign: TextAlign.right),
              Text('Wins: ' + widget.user.matchesWon.toString()),
            ])),
      ],
    );
  }
}
