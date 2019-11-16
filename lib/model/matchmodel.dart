import 'package:flutter/foundation.dart';
import 'package:esports/model/model.dart';

class MatchModel with ChangeNotifier {

  // API URL for a specific match
  static matchUrl(id) => "https://api.pandascore.co/matches/$id/";

  // Current consulted match
  Match current;

  // Get a list of matches from the API
  static Future<List<Match>> getMatches(String url) async {
    Iterable l = await API.getRequest(url);
    return (l ?? []).map((i) => Match.fromJson(i)).toList();
  }

  // Fetch specific match from the API
  Future fetch(int id) async {
    current = Match.fromJson(await API.getRequest(matchUrl(id)));
    notifyListeners();
  }
}
class LiveMatchModel with ChangeNotifier {
  // API URL for live matches
  static final liveMatchesUrl = "https://api.pandascore.co/matches/running";

  // Live matches
  List<Match> list = [];

  // Get live matches from the API
  Future fetch() async {
    list.clear();
    notifyListeners();
    list = await MatchModel.getMatches(liveMatchesUrl);
    notifyListeners();
  }
}

class TodayMatchModel with ChangeNotifier {

  // API URL for today matches
  static final todayMatchesUrl = "https://api.pandascore.co/matches/upcoming?sort=begin_at&range[begin_at]=${API.today},${API.today}";

  // Today matches
  List<Match> list = [];

  // Get today matches from the API
  Future fetch() async {
    list.clear();
    notifyListeners();
    list = (await MatchModel.getMatches(todayMatchesUrl))..removeWhere((match) => match.opponents.length < 2);
    notifyListeners();
  }
}
