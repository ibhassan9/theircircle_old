import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Widgets/JoinRequestWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';

class JoinRequestsListPage extends StatefulWidget {
  final Club club;
  final Course course;

  JoinRequestsListPage({Key key, this.club, this.course});

  @override
  _JoinRequestsListPageState createState() => _JoinRequestsListPageState();
}

class _JoinRequestsListPageState extends State<JoinRequestsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          title: Text(
            "Requests",
            style: GoogleFonts.quicksand(
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
