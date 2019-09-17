import 'package:squazzle/data/data.dart';

class HomePageViewRepo {
  final DbProvider dbProvider;
  final SharedPrefsProvider prefsProvider;
  final ApiProvider apiProvider;

  HomePageViewRepo(this.dbProvider, this.prefsProvider, this.apiProvider) {
    newActiveMatch = dbProvider.newActiveMatch();
    newPastMatch = dbProvider.newPastMatch();
  }

  Future<List<ActiveMatch>> getActiveMatches() async =>
      await dbProvider.getActiveMatches();

  Future<List<PastMatch>> getPastMatches() async =>
      await dbProvider.getPastMatches();

  Stream<ActiveMatch> newActiveMatch;

  Stream<PastMatch> newPastMatch;
}
