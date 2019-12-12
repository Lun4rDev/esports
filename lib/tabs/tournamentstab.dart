import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:esports/localizations.dart';
import 'package:esports/model/model.dart';
import 'package:esports/model/gamemodel.dart';
import 'package:esports/model/tournamentmodel.dart';
import 'package:esports/tabs/matchestab.dart';
import 'package:esports/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class TournamentsTab extends StatelessWidget {
  // i18n String getter
  static String str(BuildContext context, String key) => EsportsLocalizations.of(context).get(key);

  // Models getters
  GameModel games(context) => Provider.of<GameModel>(context, listen: false);
  static TournamentModel tournament(context) => Provider.of<TournamentModel>(context, listen: false);
  OngoingTournamentModel ongoingTournaments(context) => Provider.of<OngoingTournamentModel>(context, listen: false);
  UpcomingTournamentModel upcomingTournaments(context) => Provider.of<UpcomingTournamentModel>(context, listen: false);

  // Returns a filtered list of tournaments, keeping only the selected games
  List<Tournament> ft(context, List<Tournament> list) => List.from(list)..removeWhere((tn) => !games(context).list.contains(tn.videogame.name));

  // Takes a tournament id, opens a bottom sheet displaying the data of the tournament
  static openTournament(BuildContext context, int id) async {
    tournament(context).fetch(id);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (BuildContext context){
        return Consumer<TournamentModel>(
          builder: (context, model, child) {  
            var dateTime = API.localDateTime(tournament(context).current.beginAt);
            return Container(
            margin: EdgeInsets.all(16),
            child: model.current != null && model.current.id == id ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                      ...[Utils.image(model.current.league.imageUrl, 72),
                      SizedBox(width: 4,),],
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(model.current.videogame.name,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 20),),
                          SizedBox(height: 4,),
                          Text(model.current.league.name, 
                            style: TextStyle(fontSize: 14),),
                        ],
                      ),
                    ],),
                    Column(
                      children: <Widget>[
                        Text(dateTime.year.toString(), 
                          style: TextStyle(fontSize: 22)),
                        Text("${dateTime.month}/${dateTime.day}", 
                          style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16,),
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
                      for(var roster in tournament(context).current.expectedRoster)
                        FlatButton(
                          onPressed: () => openRoster(context, id, roster),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Utils.image(roster.team.imageUrl, 50),
                              Text(roster.team.name)
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(height: 4),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .49),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                          for(var match in model.current.matches)
                            GestureDetector(
                              onTap: () => MatchesTab.openMatch(context, match.id),
                              child: Card(
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width * .7,
                                  child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    runAlignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Text(match.name, style: TextStyle(fontSize: 16)),
                                      if(match.beginAt != null) 
                                        Text("${API.localDate(match.beginAt)} – ${API.localTime(match.beginAt)}",
                                          style: TextStyle(fontSize: 16)),
                                     ],
                                  ),
                                ),),
                            )    
                        ],
                    ),
                  ),
                )
              ]
            ) : Utils.loadingCircle
          );
          },
        );
      }
    );
  }

  // Returns a sliver with a header and a list of tournaments
  SliverStickyHeader tournamentSliver(BuildContext context, String name, List<dynamic> tList){
    var list = ft(context, tList);
    return SliverStickyHeader(
      header: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(name,
        style: GoogleFonts.convergence(fontSize: 36, fontWeight: FontWeight.bold),),
      ),
      sliver: tList.isNotEmpty ? list.isNotEmpty ? SliverList(
        delegate: SliverChildBuilderDelegate((context, index){
          var t = list[index];
            return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => openTournament(context, t.id),
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
                              Utils.image(t.league.imageUrl, 54),
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
      ) : SliverToBoxAdapter(child: Utils.nothingBox(str(context, "notournament")))
      : SliverToBoxAdapter(child: Utils.loadingCircle),
    );
  }

  // Takes an ExpectedRoster, opens a bottom sheet displaying the roster data
  static openRoster(BuildContext context, int tournamentId, ExpectedRoster roster) async {
    //await Future.delayed(Duration.zero);
    showModalBottomSheet(
      context: context,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
            Utils.image(roster.team.imageUrl, 80),
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
                        Utils.image(player.imageUrl, 100),
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

  @override
  Widget build(BuildContext context) {
    return // TOURNAMENTS TAB
          CustomScrollView(
            slivers: [
              Consumer<OngoingTournamentModel>(
                builder: (context, model, child) => tournamentSliver(context, str(context, "ongoing"), model.list) 
              ),
              Consumer<UpcomingTournamentModel>(
                builder: (context, model, child) => tournamentSliver(context, str(context, "upcoming"), model.list) 
              ),
            ]
          );
  }
}