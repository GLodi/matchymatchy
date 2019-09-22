import 'package:squazzle/data/data.dart';

class HomePageViewListRepo {
  final DbProvider dbProvider;

  HomePageViewListRepo(this.dbProvider) {
    newActiveMatches = dbProvider.newActiveMatches();
    newPastMatches = dbProvider.newPastMatches();
  }

  Future<List<ActiveMatch>> getActiveMatches() async =>
      await dbProvider.getActiveMatches();

  Future<List<PastMatch>> getPastMatches() async =>
      await dbProvider.getPastMatches();

  Stream<void> newActiveMatches;

  Stream<void> newPastMatches;
}
