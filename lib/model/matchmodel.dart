import 'package:flutter/foundation.dart';
import 'package:esports/model/model.dart';

class MatchModel with ChangeNotifier {
  // API URL for current matches 
  static final currentMatchesUrl = "https://api.pandascore.co/matches/running";
  
  // API URL for today matches
  static final todayMatchesUrl = "https://api.pandascore.co/matches/upcoming";
  
  // API URL for a specific match
  static matchUrl(id) => "https://api.pandascore.co/matches/$id/";

  // Live matches
  List<Match> live = [];

  // Today matches
  List<Match> today = [];

  // Current consulted match
  Match match;

  // Get a list of matches from the API
  Future<List<Match>> getMatches(String url) async {
    Iterable l = await API.getRequest(url);
    return l.map((i) => Match.fromJson(i)).toList();
  }

  // Get specific match from the API
  Future<Match> getMatch(int id) async {
    match = null;
    match = Match.fromJson(await API.getRequest(matchUrl(id)));
    return match;
  }

  // Get live matches from the API
  Future getLiveMatches() async {
    live.clear();
    live = await getMatches(currentMatchesUrl);
    notifyListeners();
  }

  // Get today matches from the API
  Future getTodayMatches() async {
    today.clear();
    today = (await getMatches(todayMatchesUrl)).reversed.toList();
    notifyListeners();
  }
}