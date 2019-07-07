import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:infinite_listview/infinite_listview.dart';

import 'package:squazzle/presentation/widgets/row_square_widget.dart';

class HomeBackgroundWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeBackgroundWidgetState();
  }
}

class _HomeBackgroundWidgetState extends State<HomeBackgroundWidget>
    with TickerProviderStateMixin {
  final InfiniteScrollController _infiniteController = InfiniteScrollController(
    initialScrollOffset: 0.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => applyMovement());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: InfiniteListView.builder(
          controller: _infiniteController,
          itemBuilder: (context, inte) =>
              RowSquareWidget(width: MediaQuery.of(context).size.width / 5),
        ),
      ),
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Opacity(
          opacity: 0.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.1, 0.3, 0.5, 0.6, 0.7, 0.8, 0.9],
                colors: [
                  Colors.red[300],
                  Colors.red[400],
                  Colors.red[500],
                  Colors.red[600],
                  Colors.red[700],
                  Colors.red[800],
                  Colors.red[900],
                ],
              ),
            ),
          ),
        ),
      )
    ]);
  }

  void applyMovement() {
    const minute = const Duration(seconds: 60);
    _infiniteController.animateTo(
      _infiniteController.offset + 2000.0,
      duration: minute,
      curve: Curves.linear,
    );
    Timer.periodic(minute, (Timer t) {
      _infiniteController.animateTo(
        _infiniteController.offset + 2000.0,
        duration: minute,
        curve: Curves.linear,
      );
    });
  }
}
