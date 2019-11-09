import 'package:flutter/foundation.dart';
import 'package:esports/model/model.dart';

class TournamentModel with ChangeNotifier {

  // API URL for a specific match
  static tournamentUrl(id) => "https://api.pandascore.co/tournaments/$id/";

  // API URL for current tournaments
  static final currentTournaments = "https://api.pandascore.co/tournaments/running";

  // Current consulted tournament
  Tournament current;

  // Current tournaments
  List<Tournament> currents = [];

  // Get current tournaments from the  API
  Future getCurrentTournaments() async {
    currents.clear();
    Iterable l = await API.getRequest(currentTournaments);
    currents = l.map((i) => Tournament.fromJson(i)).toList();
    notifyListeners();
  }

  // Get specific tournament from the API
  Future<Tournament> getTournament(int id) async {
    current = null;
    current = Tournament.fromJson(await API.getRequest(tournamentUrl(id)));
    return current;
  }
}