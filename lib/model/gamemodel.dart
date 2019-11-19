import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esports/model/model.dart';

class GameModel with ChangeNotifier {

  SharedPreferences prefs;

  // Shared preferences key
  String gamesKey = "GAMES";

  // List of selected games
  List<String> list = [];

  toggleGame(String game){
    if(list.contains(game)){
      list.remove(game);
    } else {
      list.add(game);
    }
    prefs.setStringList(gamesKey, list);
    notifyListeners();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    list = prefs.getStringList(gamesKey) ?? List<String>.of(API.games);
  }
}