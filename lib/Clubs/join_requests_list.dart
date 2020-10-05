import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Clubs/JoinRequestWidget.dart';
import 'package:unify/Courses/MemberWidget.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(
            "Requests",
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          backgroundColor: Colors.deepOrange,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
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
