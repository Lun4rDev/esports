import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:esports/model/matchmodel.dart';
import 'package:esports/model/model.dart';
import 'package:esports/model/tournamentmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(builder: (context) => MatchModel()),
      ChangeNotifierProvider(builder: (context) => TournamentModel()),
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

  // Current date and time
  static DateTime now = DateTime.now();
  
  // Get today's date in the API format
  static get today => "${now.year}-${now.month}-${now.day}";

  // Tabs controller
  TabController _tabController;

  // Tab index
  int _index = 0;

  MatchModel get matches => Provider.of<MatchModel>(context, listen: false);

  TournamentModel get tournaments => Provider.of<TournamentModel>(context, listen: false);

  Widget teamLogo(String url, double size) => url != null ? SizedBox(width: size, height: size, child: Image.network(url),) : SizedBox(width: size, height: size);

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
    var _match = matches.match;
    if(_match == null || id != _match.id) 
      _match = await matches.getMatch(id);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext context){
        return SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(_match.videogame.name, style: TextStyle(fontSize: 16),),
                SizedBox(height: 4,),
                Text(_match.tournament.name, style: TextStyle(fontSize: 14),),
                SizedBox(height: 16,),
                Text(_match.beginAt.substring(11, 16), 
                  style: TextStyle(fontSize: 24)),
                SizedBox(height: 16,),
                if(_match.opponents.length == 2) Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(_match.opponents[0].opponent.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)),
                        teamLogo(_match.opponents[0].opponent.imageUrl, 100),
                      ],
                    ),
                  ),
                  Text("VS", 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(_match.opponents[1].opponent.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)),
                        teamLogo(_match.opponents[1].opponent.imageUrl, 100),
                      ],
                    ),
                  ),
                ],),
                SizedBox(height: 32,),
                if(_match.liveUrl != null)
                  Container(
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Text(_match.liveUrl.replaceFirst("https://", "")),
                      onPressed: () => _launch(_match.liveUrl),
                    ),
                  )
              ],
            ),
          ),
        );
      }
    );
  }

  openTournament(int id) async {
    var _tournament = tournaments.current;
    if(_tournament == null || id != _tournament.id) 
      _tournament = await tournaments.getTournament(id);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext context){
        return SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(_tournament.videogame.name, style: TextStyle(fontSize: 16),),
                SizedBox(height: 4,),
                Text(_tournament.serie.name ?? _tournament.league.name, style: TextStyle(fontSize: 14),),
                SizedBox(height: 4,),
                Text(_tournament.name, style: TextStyle(fontSize: 14),),
                SizedBox(height: 4,),
                ...[teamLogo(_tournament.league.imageUrl, 80),
                  SizedBox(height: 4,),],
                if(_tournament.prizepool != null) 
                  ...[Text(_tournament.prizepool, style: TextStyle(fontSize: 14),),
                  SizedBox(height: 4,)],
                SizedBox(height: 16,),
                Text(_tournament.beginAt.substring(5, 10), 
                  style: TextStyle(fontSize: 24)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for(var team in _tournament.teams)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: <Widget>[
                              teamLogo(team.imageUrl, 50),
                              Text(team.name)
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for(var match in _tournament.matches)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: <Widget>[
                              // TODO : Matches
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // TODO: Rosters
              ]
            )
          )
        );
      }
    );
  }
  
  initApiData() async {
    await API.initToken();
    await matches.getLiveMatches();
    await matches.getTodayMatches();
    await tournaments.getCurrentTournaments();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener((){
      if(_tabController.index != _index) setState((){ _index = _tabController.index; });
    });
    initApiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: <Widget>[
                        Text("Live", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                        FlatButton.icon(
                          icon: Icon(Icons.refresh, color: Colors.grey,),
                          label: Text("Refresh", style: TextStyle(color: Colors.grey),),
                          onPressed: matches.getLiveMatches,
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      if(matches.live != null && matches.live.isNotEmpty) 
                        for(Match match in matches.live) 
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: GestureDetector(
                          onTap: () => openMatch(match.id),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16.0))),
                            elevation: 3,
                            child: Container(
                              width: 150,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 8,),
                                  Text(match.videogame.name, style: TextStyle(fontSize: 18,)),
                                  Text(match.tournament.name),
                                  SizedBox(height: 12,),
                                  teamLogo(match.opponents[0].opponent.imageUrl, 30),
                                  Text(match.opponents[0].opponent.name, style: TextStyle(fontSize: 16,)),
                                  Text((match.results[0].score ?? 0).toString(), style: TextStyle(fontSize: 20,)),
                                  Text((match.results[1].score ?? 0).toString(), style: TextStyle(fontSize: 20,)),
                                  Text(match.opponents[1].opponent.name, style: TextStyle(fontSize: 16,)),
                                  teamLogo(match.opponents[1].opponent.imageUrl, 30),
                                  SizedBox(height: 8,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ) else Container(
                        width: MediaQuery.of(context).size.width,
                        height: 166,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).secondaryHeaderColor)),),

                    ],
                  ),
              ),
                ),
              // TODAY SECTION
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text("Today", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                ),
              ),
              if(matches.today.isNotEmpty) SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                var match = matches.today[index];
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
                                  Text(match.beginAt.substring(11, 16), 
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
                                SizedBox(height: 4,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                },
                childCount: matches.today.length
              ),)
          ],),
          // TOURNAMENTS TAB
          SingleChildScrollView(
            child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text("Tournaments", style: TextStyle(fontSize: 38),),
              ),
              for(var t in tournaments.currents)
                Padding(
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
                              teamLogo(t.league.imageUrl, 70),
                              Column(
                                children: <Widget>[
                                  Text(t.videogame.name, style: TextStyle(fontSize: 18)),
                                  Text(t.league.name),
                                ],
                              ),
                              Text(t.beginAt.substring(5, 10), style: TextStyle(fontSize: 24),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ]
          ),)
        ],
        ),
      ),
    );
  }
}
