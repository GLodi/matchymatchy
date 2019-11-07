import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';
import 'curve_painter.dart';

class UserWidget extends StatefulWidget {
  final User user;
  final double parentHeight;
  final double parentWidth;

  UserWidget({this.user, this.parentHeight, this.parentWidth});

  @override
  State<StatefulWidget> createState() {
    return _UserWidgetState();
  }
}

enum Options { logout }

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
              width: widget.parentWidth,
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
      },
    );
  }

  Widget elements() {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: optionWidget(),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.user.photoUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: widget.parentWidth / 2,
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.user.username,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'wins: ' + widget.user.matchesWon.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget optionWidget() {
    return PopupMenuButton<Options>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: _onSelected,
      itemBuilder: (context) => <PopupMenuEntry<Options>>[
        PopupMenuItem<Options>(
          value: Options.logout,
          child: Text(
            "logout",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _onSelected(Options option) {}
}
