import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';

Color colorOne = Colors.red;
Color colorTwo = Colors.red[300];
Color colorThree = Colors.red[100];

class UserWidget extends StatefulWidget {
  final User user;
  final double height;
  final double width;

  UserWidget({Key key, this.user, this.height, this.width}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserWidget();
  }
}

class _UserWidget extends State<UserWidget> with TickerProviderStateMixin {
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
                0, -_entryAnim.value * widget.height, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200.0,
                child: Container(
                  child: elements(),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(20.0),
                      bottomRight: const Radius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget elements() {
    return Stack(
      children: <Widget>[
        Positioned(
          left: widget.width / 3,
          child: Text(widget.user.username, textAlign: TextAlign.right),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.all(10),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.user.photoUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
        Text('Wins: ' + widget.user.matchesWon.toString()),
      ],
    );
  }
}
