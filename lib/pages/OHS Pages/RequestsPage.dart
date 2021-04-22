import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Widgets/JoinRequestWidget.dart';
import 'package:unify/Widgets/MemberWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/Components/Constants.dart';

class OHSRequestsPage extends StatefulWidget {
  final Club club;
  final Course course;

  OHSRequestsPage({Key key, this.club, this.course});

  @override
  _OHSRequestsPageState createState() => _OHSRequestsPageState();
}

class _OHSRequestsPageState extends State<OHSRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          title: Text(
            "Requests",
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        ),
        body: Stack(
          children: <Widget>[
            // ListView.builder(
            //   itemCount: widget.club.joinRequests != null
            //       ? widget.club.joinRequests.length
            //       : 0,
            //   itemBuilder: (context, index) {
            //     var user = widget.club.joinRequests[index];
            //     return JoinRequestWidget(user: user, club: widget.club);
            //   },
            // ),
            FutureBuilder(
              future: getJoinRequests(widget.club),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          snapshot.data != null ? snapshot.data.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        PostUser user = snapshot.data[index];
                        return JoinRequestWidget(user: user, club: widget.club);
                      });
                } else {
                  return Container();
                }
              },
            )
          ],
        ));
  }
}
