import 'package:flutter/foundation.dart';
import 'package:esports/model/model.dart';

class TournamentModel with ChangeNotifier {
  // API URL for a specific match
  static tournamentUrl(id) => "https://api.pandascore.co/tournaments/$id/";

  // API URL for ongoing tournaments
  static final ongoingTournaments =
      "https://api.pandascore.co/tournaments/running";

  // API URL for upcoming tournaments
  static final upcomingTournaments =
      "https://api.pandascore.co/tournaments/upcoming";

  // Currently consulted tournament
  Tournament current;

  // Ongoing tournaments
  List<Tournament> ongoing = [];

  // Upcoming tournaments
  List<Tournament> upcoming = [];

  // Get current tournaments from the  API
  Future getOngoingTournaments() async {
    ongoing.clear();
    await getTournaments(ongoingTournaments).then((list) => ongoing = list);
    notifyListeners();
  }

  // Get current tournaments from the  API
  Future getUpcomingTournaments() async {
    upcoming.clear();
    await getTournaments(upcomingTournaments).then((list) => upcoming = list);
    notifyListeners();
  }

  // Get current tournaments from the  API
  Future getTournaments(String url) async {
    Iterable l = await API.getRequest(url);
    return (l ?? []).map((i) => Tournament.fromJson(i)).toList();
  }

  // Get specific tournament from the API
  Future<Tournament> getTournament(int id) async {
    current = null;
    current = Tournament.fromJson(await API.getRequest(tournamentUrl(id)));
    return current;
  }
}
