import 'package:esports/tabs/matches/open_match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:esports/model/model.dart';
import 'package:esports/model/api.dart';
import 'package:esports/model/matchmodel.dart';
import 'package:esports/utils.dart';
import 'package:google_fonts/google_fonts.dart';

/// TabView tab of the matches
class MatchesTab extends StatelessWidget {

  // Returns a filtered list of matches, keeping only the selected games
  List<Match> fm(BuildContext context, List<Match> list) => List.from(list)..removeWhere((match) => !games(context).list.contains(match.videogame.name));
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
          // LIVE SECTION
          SliverStickyHeader(
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Text(str(context, "live"), style: GoogleFonts.convergence(fontSize: 36, fontWeight: FontWeight.bold),),
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
                                        image(match.opponents[i].opponent.imageUrl, 28),
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
                  ) else SizedBox(width: MediaQuery.of(context).size.width, child: 
                      nothingBox(str(context, "nomatches")))
                  else SizedBox(width: MediaQuery.of(context).size.width, child: loadingCircle) // If no matches yet (downloading)
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
                    Text(str(context, "today"), style: GoogleFonts.convergence(fontSize: 36, fontWeight: FontWeight.bold),),
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
                                  image(match.opponents[0].opponent.imageUrl, 54)]
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
                                    image(match.opponents[1].opponent.imageUrl, 54)]
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
          ) : SliverToBoxAdapter(child: nothingBox(str(context, "nomatches")))
          : SliverToBoxAdapter(child: loadingCircle,)
      );},
        )
         
          ],);
  }
}