import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:esports/localizations.dart';
import 'package:esports/model/model.dart';
import 'package:esports/model/matchmodel.dart';
import 'package:esports/model/gamemodel.dart';
import 'package:esports/tabs/tournamentstab.dart';
import 'package:esports/utils.dart';


class MatchesTab extends StatelessWidget {
  // i18n String getter
  static String str(BuildContext context, String key) => EsportsLocalizations.of(context).get(key);

  // Models getters
  GameModel games(context) => Provider.of<GameModel>(context, listen: false);
  static MatchModel match(context) => Provider.of<MatchModel>(context, listen: false);
  LiveMatchModel liveMatches(context) => Provider.of<LiveMatchModel>(context, listen: false);
  TodayMatchModel todayMatches(context) => Provider.of<TodayMatchModel>(context, listen: false);

  // Returns a filtered list of matches, keeping only the selected games
  List<Match> fm(BuildContext context, List<Match> list) => List.from(list)..removeWhere((match) => !games(context).list.contains(match.videogame.name));

  // Launch a URL
  static _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  // Takes a match id, opens a bottom sheet displaying the data of the match
  static openMatch(BuildContext context, int id) async {
    match(context).fetch(id);
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
                      TournamentsTab.openTournament(context, _match.current.tournamentId);
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
                SizedBox(height: 26,),
                if(_match.current.opponents.length == 2) Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(_match.current.opponents[0].opponent.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Utils.image(_match.current.opponents[0].opponent.imageUrl, 80),
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
                        SizedBox(height: 8),
                        Utils.image(_match.current.opponents[1].opponent.imageUrl, 80),
                      ],
                    ),
                  ),
                ],),
                SizedBox(height: 26,),
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
                          Text("${str(context, "game")} ${game.position}"),
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
            ) : Utils.loadingCircle;
            },
          ),
        );
      
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return // MATCHES TAB
            CustomScrollView(
            slivers: [
                // LIVE SECTION
                SliverStickyHeader(
                  header: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: <Widget>[
                        Text(str(context, "live"), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                        FlatButton.icon(
                          icon: Icon(Icons.refresh, color: Colors.grey,),
                          label: Text(str(context, "refresh"), style: TextStyle(color: Colors.grey),),
                          onPressed: liveMatches(context).fetch,
                        )
                      ],
                    ),
                  ),
                  sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Consumer<LiveMatchModel>(
                    builder: (context, model, child) { 
                      var list = fm(context, model.list);
                      return Row(
                      children: <Widget>[
                        if(model.list.isNotEmpty) 
                          if(list.isNotEmpty)
                          for(Match match in fm(context, list)) 
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: GestureDetector(
                            onTap: () => openMatch(context, match.id),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16.0))),
                              elevation: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: 175,
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
                                              Utils.image(match.opponents[i].opponent.imageUrl, 28),
                                              SizedBox(width: 4,),
                                              Flexible(
                                                child: Text(match.opponents[i].opponent.name, 
                                                  softWrap: false,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.fade,
                                                  style: TextStyle(fontSize: 16,)),
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
                        ) else Utils.nothingBox(str(context, "nomatches"))
                        else SizedBox(width: MediaQuery.of(context).size.width, child: Utils.loadingCircle) // If no matches yet (downloading)
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
                  var list = fm(context, model.list);
                  return SliverStickyHeader(
                  header: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: <Widget>[
                          Text(str(context, "today"), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                          FlatButton.icon(
                            icon: Icon(Icons.refresh, color: Colors.grey,),
                            label: Text(str(context, "refresh"), style: TextStyle(color: Colors.grey),),
                            onPressed: todayMatches(context).fetch,
                          )
                        ],
                      ),
                  ),
                  sliver: model.list.isNotEmpty ? list.isNotEmpty ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                    var match = list[index];
                      return GestureDetector(
                        onTap: () => openMatch(context, match.id),
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
                                        Utils.image(match.opponents[0].opponent.imageUrl, 54)]
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
                                          Utils.image(match.opponents[1].opponent.imageUrl, 54)]
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
                ) : SliverToBoxAdapter(child: Utils.nothingBox(str(context, "nomatches")))
                : SliverToBoxAdapter(child: Utils.loadingCircle,)
            );},
              )
               
          ],);
  }
}