import 'package:esports/model/model.dart';
import 'package:esports/utils.dart';
import 'package:flutter/material.dart';

// Takes an ExpectedRoster, opens a bottom sheet displaying the roster data
openRoster(BuildContext context, ExpectedRoster roster) async {
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
            image(roster.team.imageUrl, 80),
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
                        image(player.imageUrl, 100),
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