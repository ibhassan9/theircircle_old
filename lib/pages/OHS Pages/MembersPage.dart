import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/pages/join_requests_list.dart';
import 'package:unify/Widgets/MemberWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart' as cour;
import 'package:unify/Models/user.dart';

class OHSMembersPage extends StatefulWidget {
  final List<PostUser> members;
  final Club club;
  final cour.Course course;
  final bool isCourse;

  OHSMembersPage(
      {Key key, this.members, this.club, this.course, this.isCourse});

  @override
  _OHSMembersPageState createState() => _OHSMembersPageState();
}

class _OHSMembersPageState extends State<OHSMembersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          title: Text(
            widget.isCourse
                ? "${widget.course.code} Members"
                : "${widget.club.name} Members",
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
          ),
          actions: [
            Visibility(
              visible: widget.club != null ? widget.club.admin : false,
              child: IconButton(
                icon: Icon(AntDesign.addusergroup,
                    color: Theme.of(context).accentColor),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => JoinRequestsListPage(
                                club: widget.club,
                              )));
                },
              ),
            ),
          ],
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.7,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Stack(
            children: <Widget>[
              FutureBuilder(
                future: OneHealingSpace.fetchMemberList(widget.club),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return Center(
                        child: SizedBox(
                            width: 40,
                            height: 40,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballScaleMultiple,
                              color: Theme.of(context).accentColor,
                            )));
                  else if (snap.hasData)
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: snap.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var user = snap.data[index];
                        Function delete = () {
                          showRemove(user);
                        };
                        if (widget.club != null) {
                          return MemberWidget(
                              user: user,
                              club: widget.club,
                              isCourse: widget.isCourse,
                              delete: delete);
                        } else {
                          return MemberWidget(
                              user: user,
                              club: widget.club,
                              isCourse: widget.isCourse);
                        }
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
                          Function delete = () {
                            showRemove(user);
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

  showRemove(PostUser user) {
    final act = CupertinoActionSheet(
      title: Text(
        "PROCEED?",
        style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      message: Text(
        "Are you sure you want to remove ${user.name} from your club?",
        style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      actions: [
        CupertinoActionSheetAction(
            child: Text(
              "YES",
              style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
            onPressed: () async {
              var res = await removeUserFromClub(widget.club, user);
              if (res) {
                setState(() {});
              }
              Navigator.pop(context);
            }),
        CupertinoActionSheetAction(
            child: Text(
              "Cancel",
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }
}
