import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Courses/MemberWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/user.dart';

class MembersListPage extends StatefulWidget {
  final List<PostUser> members;
  final Club club;

  MembersListPage({Key key, this.members, this.club});

  @override
  _MembersListPageState createState() => _MembersListPageState();
}

class _MembersListPageState extends State<MembersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Club Members",
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          backgroundColor: Colors.deepPurple,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          brightness: Brightness.dark,
        ),
        body: Stack(
          children: <Widget>[
            ListView.builder(
              itemCount: widget.members != null ? widget.members.length : 0,
              itemBuilder: (context, index) {
                var user = widget.members[index];
                return MemberWidget(
                  user: user,
                  club: widget.club,
                );
              },
            ),
          ],
        ));
  }
}
