import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:preload_page_view/preload_page_view.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'package:squazzle/domain/domain.dart';
import 'home_pageview_list_widget.dart';

class HomePageViewWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageViewWidgetState();
  }
}

class _HomePageViewWidgetState extends State<HomePageViewWidget> {
  PreloadPageController controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PreloadPageController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 5),
          DotsIndicator(
            dotsCount: 2,
            position: currentIndex,
            decorator: DotsDecorator(
              activeSize: Size.square(12),
            ),
          ),
          Expanded(
            child: PreloadPageView(
              controller: controller,
              reverse: false,
              preloadPagesCount: 2,
              onPageChanged: (int position) => setState(() {
                currentIndex = position;
              }),
              children: [
                Container(color: Colors.white),
                BlocProvider(
                  child: HomePageViewListWidget(),
                  bloc: kiwi.Container().resolve<HomePageViewListBloc>(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
