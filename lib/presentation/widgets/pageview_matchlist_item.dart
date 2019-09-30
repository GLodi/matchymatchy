import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:squazzle/presentation/screens/multi_screen.dart';
import 'package:squazzle/data/models/models.dart';
import 'package:squazzle/domain/domain.dart';

abstract class MatchListItem {}

class ActiveMatchItem extends StatefulWidget implements MatchListItem {
  final ActiveMatch activeMatch;

  ActiveMatchItem(this.activeMatch);

  @override
  State<StatefulWidget> createState() {
    return _ActiveMatchItemState();
  }
}

class _ActiveMatchItemState extends State<ActiveMatchItem> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.activeMatch.matchId,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              child: MultiScreen(widget.activeMatch.matchId),
              bloc: kiwi.Container().resolve<MultiBloc>(),
            ),
          ),
        ),
        child: Container(
          height: 100,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
          child: FutureBuilder(
              future: getImageColor(widget.activeMatch.enemyUrl),
              builder: (context, snapshot) {
                return Card(
                  color: snapshot.data,
                  child: elements(),
                );
              }),
        ),
      ),
    );
  }

  Widget elements() {
    return Stack(
      children: [
        Center(
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.activeMatch.enemyUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        Text(
          widget.activeMatch.gfid.toString(),
          style: TextStyle(color: Colors.black),
        )
      ],
    );
  }

  Future<Color> getImageColor(String url) async {
    PaletteGenerator gen = await PaletteGenerator.fromImage(
      Image(
        image: CachedNetworkImageProvider(widget.activeMatch.enemyUrl),
      ),
    );
    return gen.vibrantColor.color;
  }
}

class PastMatchItem extends StatefulWidget implements MatchListItem {
  final PastMatch pastMatch;

  PastMatchItem(this.pastMatch);

  @override
  State<StatefulWidget> createState() {
    return _PastMatchItemState();
  }
}

class _PastMatchItemState extends State<PastMatchItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text('past' + widget.pastMatch.moves.toString(),
          style: TextStyle(color: Colors.black)),
    );
  }
}
