import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:squazzle/data/models/models.dart';

class UserWidget extends StatefulWidget {
  final User user;
  final double height;
  final double width;

  UserWidget({Key key, this.user, this.height, this.width}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserWidget(user: user, height: height, width: width);
  }
}

class _UserWidget extends State<UserWidget> with TickerProviderStateMixin {
  final User user;
  final double height;
  final double width;
  AnimationController _entryAnimCont;
  Animation _entryAnim;

  _UserWidget({this.user, this.height, this.width});

  @override
  void initState() {
    // TODO: implement initState
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
            transform:
                Matrix4.translationValues(0, _entryAnim.value * height, 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100.0,
                width: width,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 10.0,
                      )
                    ],
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: width / 3,
                        child: Text(user.username, textAlign: TextAlign.right),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.imageUrl,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      Text('Wins: ' + user.matchesWon.toString()),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
