import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/pages/club_page.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/user.dart';

class ClubWidget extends StatefulWidget {
  final Club club;
  final Function delete;

  ClubWidget({Key key, @required this.club, @required this.delete})
      : super(key: key);

  @override
  _ClubWidgetState createState() => _ClubWidgetState();
}

class _ClubWidgetState extends State<ClubWidget> {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (widget.club.admin ||
              widget.club.inClub ||
              widget.club.privacy == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClubPage(
                          club: widget.club,
                        )));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: Row(
                        children: <Widget>[
                          Icon(AntDesign.team, color: Colors.white, size: 15.0),
                          Text(
                            "${widget.club.memberCount}",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.club.name.trim().isNotEmpty
                                          ? widget.club.name
                                          : 'No name available',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Visibility(
                                      visible: _fAuth.currentUser.uid ==
                                          widget.club.adminId,
                                      child: InkWell(
                                          onTap: () {
                                            final act = CupertinoActionSheet(
                                              title: Text(
                                                "PROCEED?",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                              message: Text(
                                                "Are you sure you want to delete this club?",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                              actions: [
                                                CupertinoActionSheetAction(
                                                    child: Text(
                                                      "YES",
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor),
                                                    ),
                                                    onPressed: () {
                                                      widget.delete();
                                                    }),
                                                CupertinoActionSheetAction(
                                                    child: Text(
                                                      "Cancel",
                                                      style:
                                                          GoogleFonts.quicksand(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.red),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }),
                                              ],
                                            );
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        act);
                                          },
                                          child: Icon(AntDesign.delete,
                                              size: 15.0)))
                                ],
                              ),
                              Text(
                                widget.club.description.isNotEmpty
                                    ? widget.club.description
                                    : "No description available",
                                style: GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.5)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          )),
                          SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  if (widget.club.admin) {
                                  } else if (widget.club.inClub) {
                                    setState(() {
                                      widget.club.inClub = false;
                                      widget.club.memberCount -= 1;
                                    });
                                    await leaveClub(widget.club);
                                  } else if (widget.club.privacy == 0) {
                                    await joinClub(widget.club);
                                    var user =
                                        await getUser(widget.club.adminId);
                                    var token = user.deviceToken;
                                    await sendPushClub(widget.club, 6, token,
                                        "", null, user.id);
                                    setState(() {
                                      widget.club.inClub = true;
                                      widget.club.memberCount += 1;
                                    });
                                  } else if (widget.club.privacy == 1) {
                                    if (widget.club.requested) {
                                      setState(() {
                                        widget.club.requested = false;
                                      });
                                      await removeJoinRequest(widget.club);
                                    } else {
                                      setState(() {
                                        widget.club.requested = true;
                                      });
                                      await requestToJoin(widget.club);
                                      var user =
                                          await getUser(widget.club.adminId);
                                      var token = user.deviceToken;
                                      await sendPushClub(widget.club, 5, token,
                                          "", null, user.id);
                                    }
                                  }
                                },
                                child: Text(
                                  status(),
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.lightBlue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  String status() {
    if (widget.club.admin) {
      return 'Created by you';
    } else if (widget.club.inClub) {
      return 'Leave Club';
    } else if (widget.club.privacy == 0) {
      return 'Join Club';
    } else {
      if (widget.club.requested) {
        return 'Awaiting Approval';
      } else {
        return 'Request to Join';
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
  }
}
