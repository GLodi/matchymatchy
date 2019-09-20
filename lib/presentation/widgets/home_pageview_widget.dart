import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:page_indicator/page_indicator.dart';

import 'package:squazzle/domain/domain.dart';
import 'home_pageview_list_widget.dart';

class HomePageViewWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageViewWidgetState();
  }
}

class _HomePageViewWidgetState extends State<HomePageViewWidget> {
  final GlobalKey<PageContainerState> _pageViewKey = GlobalKey();

  PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageIndicatorContainer(
        key: _pageViewKey,
        child: PageView(
          controller: controller,
          reverse: false,
          children: <Widget>[
            Container(color: Colors.white),
            BlocProvider(
              child: HomePageViewListWidget(),
              bloc: kiwi.Container().resolve<HomePageViewListBloc>(),
            ),
          ],
        ),
        align: IndicatorAlign.top,
        length: 2,
        indicatorSpace: 10.0,
        indicatorSelectorColor: Colors.blue[800],
        indicatorColor: Colors.grey[300],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
