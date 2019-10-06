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
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    controller = PreloadPageController(initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 5),
          DotsIndicator(
            dotsCount: 3,
            position: currentIndex,
            decorator: DotsDecorator(
              activeSize: Size.square(12),
            ),
          ),
          Expanded(
            child: PreloadPageView(
              controller: controller,
              reverse: false,
              preloadPagesCount: 3,
              onPageChanged: (int position) => setState(() {
                currentIndex = position;
              }),
              children: [
                Center(
                  child: Text(
                    'Friends',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                BlocProvider(
                  child: HomePageViewListWidget(),
                  bloc: kiwi.Container().resolve<HomePageViewListBloc>(),
                ),
                Center(
                  child: Text(
                    'News',
                    style: TextStyle(color: Colors.black),
                  ),
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
