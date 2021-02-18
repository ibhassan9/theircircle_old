import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/pages/RoomPage.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/Components/Constants.dart';

class RoomWidget extends StatefulWidget {
  final Room room;
  final Function reload;
  RoomWidget({Key key, this.room, this.reload}) : super(key: key);

  @override
  _RoomWidgetState createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
  Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.room.isLocked == false ||
            widget.room.adminId == FirebaseAuth.instance.currentUser.uid) {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RoomPage(room: widget.room)))
              .then((value) {
            if (value != null && value == true) {
              widget.reload();
            }
          });
        } else {
          Toast.show('You need to be part of this room to enter', context);
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
                    color: color,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(AntDesign.team, color: Colors.white, size: 15.0),
                        Text(
                          widget.room.members.length.toString(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              widget.room.isLocked
                                  ? Unicon(UniconData.uniLock,
                                      color: Theme.of(context).accentColor,
                                      size: 15.0)
                                  : Container(),
                              widget.room.isLocked
                                  ? SizedBox(width: 5.0)
                                  : Container(),
                              Flexible(
                                child: Text(
                                  widget.room.isLocked
                                      ? '• ${widget.room.name}'
                                      : widget.room.name,
                                  maxLines: 1,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.room.description,
                            style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          )
                        ],
                      )),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              widget.room.isAdmin
                                  ? 'Created by you'.toUpperCase()
                                  : 'View Room'.toUpperCase(),
                              style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.lightBlue)),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: 3.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: widget.room.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                // Container(
                //   width: 50,
                //   height: 50,
                //   decoration: BoxDecoration(
                //       color: Theme.of(context).dividerColor,
                //       borderRadius: BorderRadius.circular(5.0)),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // String status() {
  //   if (widget.course.inCourse) {
  //     return 'Leave Course';
  //   } else {
  //     return 'Join Course';
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
  }
}
