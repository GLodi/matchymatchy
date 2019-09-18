import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';

import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';
import 'package:squazzle/presentation/widgets/home_match_list_widget.dart';

class HomePageViewWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageViewWidgetState();
  }
}

class _HomePageViewWidgetState extends State<HomePageViewWidget> {
  final GlobalKey<PageContainerState> _pageViewKey = GlobalKey();

  HomePageViewBloc bloc;
  PageController controller;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HomePageViewBloc>(context);
    bloc.emitEvent(HomePageViewEvent(type: HomePageViewEventType.start));
    controller = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActiveMatch>>(
      stream: bloc.activeMatches,
      initialData: [],
      builder: (context, snapshot1) {
        return StreamBuilder<List<PastMatch>>(
          stream: bloc.pastMatches,
          initialData: [],
          builder: (context2, snapshot2) =>
              centerPageView(snapshot1.data, snapshot2.data),
        );
      },
    );
  }

  Widget centerPageView(
      List<ActiveMatch> activeMatches, List<PastMatch> pastMatches) {
    return Expanded(
      child: PageIndicatorContainer(
        key: _pageViewKey,
        child: PageView(
          children: <Widget>[
            Container(color: Colors.white),
            HomeMatchList(
                activeMatches: activeMatches, pastMatches: pastMatches),
          ],
          controller: controller,
          reverse: false,
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
    bloc.dispose();
    controller.dispose();
    super.dispose();
  }
}
