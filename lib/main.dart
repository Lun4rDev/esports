import 'dart:async';
import 'dart:core';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:esports/localizations.dart';
import 'package:esports/model/api.dart';
import 'package:esports/model/gamemodel.dart';
import 'package:esports/model/matchmodel.dart';
import 'package:esports/model/tournamentmodel.dart';
import 'package:esports/tabs/matches/matchestab.dart';
import 'package:esports/tabs/tournaments/tournamentstab.dart';
void main() => runApp(
  MultiProvider(
    providers: [
      // Game model provider
      ChangeNotifierProvider(create: (context) => GameModel()),

      // Match models providers
      ChangeNotifierProvider(create: (context) => MatchModel()),
      ChangeNotifierProvider(create: (context) => LiveMatchModel()),
      ChangeNotifierProvider(create: (context) => TodayMatchModel()),

      // Tournament models providers
      ChangeNotifierProvider(create: (context) => TournamentModel()),
      ChangeNotifierProvider(create: (context) => OngoingTournamentModel()),
      ChangeNotifierProvider(create: (context) => UpcomingTournamentModel()),
    ],
    child: EsportsApp()
  )
);

class EsportsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          EsportsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('fr', 'FR'), // French
        ],
      title: 'Esports',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorDark: Color(0xFF00adb5),
        accentColor: Color(0xFF00adb5),
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      home: EsportsPage(title: 'Esports'),
    );
  }
}

class EsportsPage extends StatefulWidget {
  EsportsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EsportsPageState createState() => _EsportsPageState();
}

class _EsportsPageState extends State<EsportsPage> with SingleTickerProviderStateMixin {

  // Tabs controller
  TabController _tabController;

  // Network state subscription
  StreamSubscription subscription;

  // Has access to Internet
  bool hasInternet = true;

  // Tab index
  int _index = 0;

  // i18n String getter
  String str(String key) => EsportsLocalizations.of(context).get(key);

  // Models getters
  GameModel get games => Provider.of<GameModel>(context, listen: false);
  LiveMatchModel get liveMatches => Provider.of<LiveMatchModel>(context, listen: false);
  TodayMatchModel get todayMatches => Provider.of<TodayMatchModel>(context, listen: false);
  OngoingTournamentModel get ongoingTournaments => Provider.of<OngoingTournamentModel>(context, listen: false);
  UpcomingTournamentModel get upcomingTournaments => Provider.of<UpcomingTournamentModel>(context, listen: false);

  // Notifies all consumers
  notifyListeners() => <ChangeNotifier>[liveMatches, todayMatches, ongoingTournaments, upcomingTournaments].forEach((cn) => cn.notifyListeners());

  // Initializes the providers data
  initApiData() async {
    await API.initToken();
    liveMatches.fetch();
    await todayMatches.fetch();
    await ongoingTournaments.fetch();
    await upcomingTournaments.fetch();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener((){
      if(_tabController.index != _index) setState((){ _index = _tabController.index; });
    });
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(hasInternet && result == ConnectivityResult.none){
        setState(() => hasInternet = false);
      } 
      else if(!hasInternet && result != ConnectivityResult.none){
        setState(() => hasInternet = true);
        initApiData();
      }
    });
    games.init();
    initApiData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder:(context, model, child){ 
        return Scaffold(
        floatingActionButton: SpeedDial(
          closeManually: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Image.asset("assets/icon.png",
            width:  32,
            height: 32,),
          children: [
            for(var game in API.games)
              SpeedDialChild(
                label: game,
                labelStyle: TextStyle(fontSize: 18, color: Colors.black),
                onTap: () => model.toggleGame(game),
                backgroundColor: model.list.contains(game) ? Theme.of(context).accentColor : Colors.grey
              )
          ],
        ),
        bottomNavigationBar: TabBar(
          indicatorWeight: 1,
          controller: _tabController,
          onTap: (int index) {
            setState(() {
              _index = index;
              _tabController.animateTo(index);
            });
          },
          tabs: <Widget>[
            Tab(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.compare_arrows, size: 16),
                SizedBox(width: 8,),
                Text(str("matches")),
              ],
            )),
            Tab(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.equalizer, size: 16,),
                SizedBox(width: 8,),
                Text(str("tournaments")),
              ],
            )),
          ],
        ),
        body: SafeArea(
          child: hasInternet ? TabBarView(
            controller: _tabController,
            children: [
              MatchesTab(),
              TournamentsTab()
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.portable_wifi_off),
              SizedBox(width: MediaQuery.of(context).size.width),
              Text(str("nointernet"))
            ],
          ),
        ),
      );}
    );
  }
}
