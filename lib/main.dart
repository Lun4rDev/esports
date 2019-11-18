import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:esports/model/matchmodel.dart';
import 'package:esports/model/model.dart';
import 'package:esports/model/tournamentmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      // Match models providers
      ChangeNotifierProvider(builder: (context) => MatchModel()),
      ChangeNotifierProvider(builder: (context) => LiveMatchModel()),
      ChangeNotifierProvider(builder: (context) => TodayMatchModel()),

      // Tournament models providers
      ChangeNotifierProvider(builder: (context) => TournamentModel()),
      ChangeNotifierProvider(builder: (context) => OngoingTournamentModel()),
      ChangeNotifierProvider(builder: (context) => UpcomingTournamentModel()),
    ],
    child: EsportsApp()
  )
);

class EsportsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esports',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorDark: Color(0xFF00adb5),
        accentColor: Color(0xFF00adb5),
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

  SharedPreferences prefs;

  String gamesKey = "GAMES";
  
  // Tabs controller
  TabController _tabController;

  // Tab index
  int _index = 0;

  // Match models providers
  MatchModel get match => Provider.of<MatchModel>(context, listen: false);
  LiveMatchModel get liveMatches => Provider.of<LiveMatchModel>(context, listen: false);
  TodayMatchModel get todayMatches => Provider.of<TodayMatchModel>(context, listen: false);

  // Tournament models providers
  TournamentModel get tournament => Provider.of<TournamentModel>(context, listen: false);
  OngoingTournamentModel get ongoingTournaments => Provider.of<OngoingTournamentModel>(context, listen: false);
  UpcomingTournamentModel get upcomingTournaments => Provider.of<UpcomingTournamentModel>(context, listen: false);
  notifyListeners() => <ChangeNotifier>[liveMatches, todayMatches, ongoingTournaments, upcomingTournaments].forEach((cn) => cn.notifyListeners());


  List<Match> fm(List<Match> list) => List.from(list)..removeWhere((match) => !games.contains(match.videogame.name));
  List<Tournament> ft(List<Tournament> list) => List.from(list)..removeWhere((tn) => !games.contains(tn.videogame.name));

  // Sized square logo fetched from the web
  Widget teamLogo(String url, double size) => url != null 
    ? SizedBox(width: size, height: size, child: Image.network(url),) 
    : SizedBox(width: size, height: size);

  // Loading animation
  Widget get loadingCircle => Container(
    width: MediaQuery.of(context).size.width,
    height: 166,
    alignment: Alignment.center,
    child: CircularProgressIndicator(strokeWidth: 1,),);

  Widget nothingBox(String label) => SizedBox( // If no match corresponding to filters
    width: MediaQuery.of(context).size.width,
    height: 175, 
    child: Center(child: Text(label, style: TextStyle(color: Colors.grey)),),);

  // List of selected games
  List<String> games = [];

  toggleGame(String game){
    setState(() {
      if(games.contains(game)){
        games.remove(game);
      } else {
        games.add(game);
      }
    });
    prefs.setStringList(gamesKey, games);
    notifyListeners();
  }
  

  // Launch a URL
  _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Open a specific match in a bottom sheet
  openMatch(int id) async {
    match.fetch(id);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext context){
        return Container(
          margin: EdgeInsets.all(16),
          child: Consumer<MatchModel>(
            builder: (context, _match, child) { 
              return _match.current != null && _match.current.id == id ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                      Navigator.pop(context);
                      openTournament(_match.current.tournamentId);
                    },
                child: Row(children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_match.current.videogame.name, style: TextStyle(fontSize: 18),),
                        SizedBox(height: 4,),
                        Text(_match.current.league.name,
                          softWrap: false, 
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: 14),),
                      ],
                    )),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                      Text(_match.current.serie.name ?? _match.current.serie.fullName ?? "", style: TextStyle(fontSize: 14),),
                      SizedBox(height: 4,),
                      Text(_match.current.tournament.name, style: TextStyle(fontSize: 14),),
                    ],),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(API.localDate(_match.current.beginAt), 
                          style: TextStyle(fontSize: 18)),
                        Text(API.localTime(_match.current.beginAt), 
                          style: TextStyle(fontSize: 26)),
                      ],),
                  ),
                  
                ],)),
                SizedBox(height: 16,),
                if(_match.current.opponents.length == 2) Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(_match.current.opponents[0].opponent.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)),
                        teamLogo(_match.current.opponents[0].opponent.imageUrl, 80),
                      ],
                    ),
                  ),
                  Text("VS", 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(_match.current.opponents[1].opponent.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)),
                        teamLogo(_match.current.opponents[1].opponent.imageUrl, 80),
                      ],
                    ),
                  ),
                ],),
                SizedBox(height: 16,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                    for(var game in _match.current.games)
                      Card(child: Container(
                        width: 116,
                        height: 58,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          Text("Game ${game.position}"),
                          Text(game.finished  
                            ? _match.current.opponents.firstWhere((o) => o.opponent.id == game.winner.id).opponent.name
                            : game.beginAt != null ? API.localTime(game.beginAt) : "N/A")
                        ],),
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                if(_match.current.liveUrl != null)
                  Container(
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Text(_match.current.liveUrl.replaceFirst("https://", "")),
                      onPressed: () => _launch(_match.current.liveUrl),
                    ),
                  )
              ],
            ) : loadingCircle;
            },
          ),
        );
      
      }
    );
  }

  openTournament(int id) async {
    tournament.fetch(id);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext context){
        return SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          child: Consumer<TournamentModel>(
            builder: (context, model, child) {  
              return Container(
              margin: EdgeInsets.all(16),
              child: model.current != null && model.current.id == id ? Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                        ...[teamLogo(model.current.league.imageUrl, 72),
                        SizedBox(width: 4,),],
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(model.current.videogame.name,
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 20),),
                            SizedBox(height: 4,),
                            Text(model.current.league.name, 
                              style: TextStyle(fontSize: 13),),
                          ],
                        ),
                      ],),
                      Text(API.localDate(tournament.current.beginAt), 
                        style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(model.current.serie.name ?? model.current.serie.fullName ?? "", style: TextStyle(fontSize: 18),),
                        Text(" – "),
                        Text(model.current.name, style: TextStyle(fontSize: 18),),
                    ],
                  ),
                  SizedBox(height: 4,),
                  if(model.current.prizepool != null) 
                    ...[Text(model.current.prizepool, style: TextStyle(fontSize: 14),),
                    SizedBox(height: 4,)],
                  Divider(height: 32),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for(var roster in tournament.current.expectedRoster)
                          FlatButton(
                            onPressed: () => openRoster(id, roster),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: <Widget>[
                                teamLogo(roster.team.imageUrl, 50),
                                Text(roster.team.name)
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // TODO: Rosters
                  // TODO : Matches
                  // Matches doesn't seem to have relevant data in the free plan ?
                  /*SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for(var match in tournament.current.)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Card(
                              child: Column(
                                children: <Widget>[
                                  
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),*/
                ]
              ) : loadingCircle
            );
            },
          ) 
        );
      }
    );
  }

  openRoster(int tournamentId, ExpectedRoster roster) async {
    //await Future.delayed(Duration.zero);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(16),
          child: Column(children: <Widget>[
            teamLogo(roster.team.imageUrl, 80),
            SizedBox(height: 4),
            Text(roster.team.name, style: TextStyle(fontSize: 24)),
            SizedBox(height: 26, child: Divider()),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: <Widget>[
                for(var player in roster.players)
                  ...[
                    Column(
                      children: <Widget>[
                        teamLogo(player.imageUrl, 100),
                        SizedBox(height: 4,),
                        if(player.role != null) Text(player.role),
                        Text(player.name, style: TextStyle(fontSize: 20)),
                        if(player.firstName != null) Text("${player.firstName} ${player.lastName}"),
                        if(player.hometown != null) Text(player.hometown, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(width: 16,)
                  ]
              ]),
            )
          ],),
        );
      }
    );
  }

  SliverStickyHeader tournamentSliver(String name, List<dynamic> tList){
    var list = ft(tList);
    return SliverStickyHeader(
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(name, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
      ),
      sliver: tList.isNotEmpty ? list.isNotEmpty ? SliverList(
        delegate: SliverChildBuilderDelegate((context, index){
          var t = list[index];
            return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => openTournament(t.id),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 16,
                      margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      child: Card(
                        elevation: 3.3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              teamLogo(t.league.imageUrl, 54),
                              Column(
                                children: <Widget>[
                                  Text(t.videogame.name, style: TextStyle(fontSize: 18)),
                                  Text(t.league.name, style: TextStyle(fontSize: 13)),
                                ],
                              ),
                              Text(API.localDate(t.beginAt), style: TextStyle(fontSize: 20),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
          },
          childCount: list.length
        ),
      ) : SliverToBoxAdapter(child: nothingBox("No tournaments"))
      : SliverToBoxAdapter(child: loadingCircle),
    );
  }
  
  initApiData() async {
    await API.initToken();
    await liveMatches.fetch();
    await todayMatches.fetch();
    await ongoingTournaments.fetch();
    await upcomingTournaments.fetch();
  }

  initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      games = prefs.getStringList(gamesKey) ?? List<String>.of(API.games);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener((){
      if(_tabController.index != _index) setState((){ _index = _tabController.index; });
    });
    initSharedPreferences();
    initApiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        closeManually: true,
        child: Icon(Icons.games),
        children: [
          for(var game in API.games)
            SpeedDialChild(
              label: game,
              labelStyle: TextStyle(fontSize: 18, color: Colors.black),
              onTap: () => toggleGame(game),
              backgroundColor: games.contains(game) ? Theme.of(context).accentColor : Colors.grey
            )
        ],
      ),
      bottomNavigationBar: TabBar(
        indicatorWeight: 1,
        //selectedItemColor: Theme.of(),
        //unselectedItemColor: Colors.black,
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
              Text("Matches"),
            ],
          )),
          Tab(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.equalizer, size: 16,),
              SizedBox(width: 8,),
              Text("Tournaments"),
            ],
          )),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // MATCHES TAB
            CustomScrollView(
            slivers: [
                // LIVE SECTION
                SliverStickyHeader(
                  header: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: <Widget>[
                        Text("Live", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                        FlatButton.icon(
                          icon: Icon(Icons.refresh, color: Colors.grey,),
                          label: Text("Refresh", style: TextStyle(color: Colors.grey),),
                          onPressed: liveMatches.fetch,
                        )
                      ],
                    ),
                  ),
                  sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Consumer<LiveMatchModel>(
                    builder: (context, model, child) { 
                      var list = fm(model.list);
                      return Row(
                      children: <Widget>[
                        if(model.list.isNotEmpty) 
                          if(list.isNotEmpty)
                          for(Match match in fm(list)) 
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: GestureDetector(
                            onTap: () => openMatch(match.id),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16.0))),
                              elevation: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: 190,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 10,),
                                    Text(match.videogame.name, style: TextStyle(fontSize: 18,)),
                                    SizedBox(height: 2,),
                                    Text(match.tournament.name),
                                    SizedBox(height: 12,),
                                    for(var i = 0; i < match.opponents.length; i++)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: Row(children: <Widget>[
                                              teamLogo(match.opponents[i].opponent.imageUrl, 28),
                                              SizedBox(width: 4,),
                                              Flexible(
                                                child: Text(match.opponents[i].opponent.name, 
                                                    softWrap: false,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(fontSize: 18,)),
                                              ),
                                            ],),
                                          ),
                                        SizedBox(width: 4,),
                                        Text((match.results[i].score ?? 0).toString(), style: TextStyle(fontSize: 20,)),
                                      ],),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ) else nothingBox("No matches")
                        else loadingCircle // If no matches yet (downloading)
                      ],
                    );
                    },
                ),
                  ),
                ),
              ),
              // TODAY SECTION
              Consumer<TodayMatchModel>(
                  builder: (context, model, child) {
                  var list = fm(model.list);
                  return SliverStickyHeader(
                  header: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: <Widget>[
                          Text("Today", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                          FlatButton.icon(
                            icon: Icon(Icons.refresh, color: Colors.grey,),
                            label: Text("Refresh", style: TextStyle(color: Colors.grey),),
                            onPressed: todayMatches.fetch,
                          )
                        ],
                      ),
                  ),
                  sliver: model.list.isNotEmpty ? list.isNotEmpty ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                    var match = list[index];
                      return GestureDetector(
                        onTap: () => openMatch(match.id),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 16,
                          margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16.0))),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                    Column(children: <Widget>[
                                      Text(match.videogame.name, style: TextStyle(fontSize: 16),),
                                      Text(match.tournament.name, style: TextStyle(fontSize: 12),),
                                    ],),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                      width: 1,
                                      height: 32,
                                      color: Theme.of(context).accentColor),
                                    Text(API.localTime(match.beginAt),
                                    style: TextStyle(fontSize: 24)),
                                  ],),
                                  SizedBox(height: 12,),
                                  if(match.opponents.length == 2) Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                    Expanded(
                                      child: Column(children: <Widget>[
                                        Text(match.opponents[0].opponent.name, 
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 18)),
                                        ...[SizedBox(height: 4,),
                                        teamLogo(match.opponents[0].opponent.imageUrl, 54)]
                                      ],),
                                    ),
                                    Text("VS", 
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24)),
                                    Expanded(
                                      child: Column(children: <Widget>[
                                          Text(match.opponents[1].opponent.name, 
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 18)),
                                          ...[SizedBox(height: 4,),
                                          teamLogo(match.opponents[1].opponent.imageUrl, 54)]
                                        ],
                                      ),
                                    ),
                                  ],),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                  },
                  childCount: list.length
                ),
                ) : SliverToBoxAdapter(child: nothingBox("No matches"))
                : SliverToBoxAdapter(child: loadingCircle,)
            );},
              )
               
          ],),
          // TOURNAMENTS TAB
          CustomScrollView(
            slivers: [
              Consumer<OngoingTournamentModel>(
                builder: (context, model, child) => tournamentSliver("Ongoing", model.list) 
              ),
              Consumer<UpcomingTournamentModel>(
                builder: (context, model, child) => tournamentSliver("Upcoming", model.list) 
              ),
            ]
          ),
        ],
        ),
      ),
    );
  }
}
