import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Models/club.dart';

class AssignmentWidget extends StatefulWidget {
  final Assignment assignment;
  final String timeAgo;
  final Club club;
  final Function delete;

  AssignmentWidget(
      {Key key,
      @required this.assignment,
      @required this.timeAgo,
      @required this.club,
      @required this.delete})
      : super(key: key);

  @override
  _AssignmentWidgetState createState() => _AssignmentWidgetState();
}

class _AssignmentWidgetState extends State<AssignmentWidget> {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Color color() {
      Random random = new Random();
      int index = random.nextInt(6);
      switch (index) {
        case 1:
          {
            return Colors.deepOrangeAccent;
          }
          break;
        case 2:
          {
            return Colors.deepPurpleAccent;
          }
          break;
        case 3:
          {
            return Colors.blueAccent;
          }
          break;
        case 4:
          {
            return Colors.purpleAccent;
          }
          break;
        case 5:
          {
            return Colors.redAccent;
          }
          break;
        default:
          {
            return Colors.indigoAccent;
          }
          break;
      }
    }

    return InkWell(
      onTap: () {},
      child: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(height: 100, width: 3.0, color: color()),
              SizedBox(width: 15.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Created By: " +
                                  (_fAuth.currentUser.uid ==
                                          widget.assignment.userId
                                      ? 'You'
                                      : widget.assignment.createdBy),
                              style: GoogleFonts.quicksand(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).accentColor),
                            ),
                            Visibility(
                              visible: _fAuth.currentUser.uid ==
                                      widget.assignment.userId
                                  ? true
                                  : widget.club != null &&
                                          _fAuth.currentUser.uid ==
                                              widget.club.adminId
                                      ? true
                                      : false,
                              // visible: _fAuth.currentUser.uid ==
                              //             widget.assignment.userId ||
                              //         widget.club != null
                              //     ? widget.club.adminId == null
                              //         ? false
                              //         : _fAuth.currentUser.uid ==
                              //             widget.club.adminId
                              //     : false,
                              child: InkWell(
                                onTap: () {
                                  final act = CupertinoActionSheet(
                                      title: Text(
                                        'Delete',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      message: Text(
                                        'Are you sure you want to delete this?',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      actions: [
                                        CupertinoActionSheetAction(
                                            child: Text(
                                              "YES",
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                            onPressed: () async {
                                              widget.delete();
                                              Navigator.pop(context);
                                            }),
                                        CupertinoActionSheetAction(
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.red),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }),
                                      ]);
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) => act);
                                },
                                child: Icon(AntDesign.delete, size: 15),
                              ),
                            )
                          ],
                        ),
                        Divider(),
                        Text(
                          widget.assignment.title,
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        Divider(),
                        Text(
                          widget.assignment.description,
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        Divider(),
                      ],
                    )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Due: " + widget.assignment.timeDue,
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
