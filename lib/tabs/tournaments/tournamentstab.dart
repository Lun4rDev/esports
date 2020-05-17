import 'package:esports/tabs/tournaments/open_tournament.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:esports/model/model.dart';
import 'package:esports/model/api.dart';
import 'package:esports/model/tournamentmodel.dart';
import 'package:esports/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class TournamentsTab extends StatelessWidget {

  // Returns a filtered list of tournaments, keeping only the selected games
  List<Tournament> ft(context, List<Tournament> list) => List.from(list)..removeWhere((tn) => !games(context).list.contains(tn.videogame.name));

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
                              image(t.league.imageUrl, 54),
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
      ) : SliverToBoxAdapter(child: nothingBox(str(context, "notournament")))
      : SliverToBoxAdapter(child: loadingCircle),
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