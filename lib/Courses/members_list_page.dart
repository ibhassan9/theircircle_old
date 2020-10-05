import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Courses/MemberWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart' as cour;
import 'package:unify/Models/user.dart';

class MembersListPage extends StatefulWidget {
  final List<PostUser> members;
  final Club club;
  final cour.Course course;
  final bool isCourse;

  MembersListPage(
      {Key key, this.members, this.club, this.course, this.isCourse});

  @override
  _MembersListPageState createState() => _MembersListPageState();
}

class _MembersListPageState extends State<MembersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text(
            widget.isCourse
                ? "${widget.course.code} Members"
                : "${widget.club.name} Members",
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.7,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Stack(
            children: <Widget>[
              FutureBuilder(
                future: cour.fetchMemberList(widget.course, widget.club),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ));
                  else if (snap.hasData)
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: snap.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var user = snap.data[index];
                        return MemberWidget(
                            user: user,
                            club: widget.club,
                            isCourse: widget.isCourse);
                      },
                    );
                  else if (snap.hasError)
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: widget.members.length,
                      itemBuilder: (BuildContext context, int index) {
                        var user = widget.members[index];
                        if (widget.club != null) {
                          Function delete = () async {
                            var res =
                                await removeUserFromClub(widget.club, user);
                            if (res) {
                              setState(() {});
                            }
                          };
                          return MemberWidget(
                            user: user,
                            club: widget.club,
                            isCourse: widget.isCourse,
                            delete: delete,
                          );
                        } else {
                          return MemberWidget(
                              user: user,
                              club: widget.club,
                              isCourse: widget.isCourse);
                        }
                      },
                    );
                  else
                    return Text('None');
                },
              )
            ],
          ),
        ));
  }
}
