import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:toast/toast.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/pages/RoomPage.dart';
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
      onTap: () async {
        bool live = await Room.isLive(id: widget.room.id);
        if (!live) {
          Constants.roomNA(context);
          return;
        }
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  flex: 0,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(AntDesign.team,
                                  color: Colors.white, size: 15.0),
                              Text(
                                widget.room.memberCount.toString(),
                                style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Visibility(
                        visible: widget.room.inRoom || widget.room.isAdmin,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: LoadingIndicator(
                              indicatorType: Indicator.ballScale, color: color),
                        ),
                      ),
                    ],
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
                              // widget.room.isLocked
                              //     ? Unicon(UniconData.uniLock,
                              //         color: Theme.of(context).accentColor,
                              //         size: 15.0)
                              //     : Container(),
                              // widget.room.isLocked
                              //     ? SizedBox(width: 5.0)
                              //     : Container(),
                              Flexible(
                                child: Text(
                                  widget.room.isLocked
                                      ? '🔒 • ${widget.room.name}'
                                      : widget.room.name,
                                  maxLines: 2,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "🗣️ " + widget.room.description,
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          )
                        ],
                      )),
                      SizedBox(height: 5.0),
                      Text(
                        "Current Members:",
                        style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMembersList(),
                      ),
                      SizedBox(height: 5.0),
                      Text(widget.room.memberCount.toString() + " student(s)",
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: color)),
                      SizedBox(height: 5.0),
                    ],
                  ),
                ),
                SizedBox(width: 3.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    imageUrl: widget.room.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildMembersList() {
    List<Widget> members = [];
    int i = 0;
    for (var member in widget.room.members) {
      if (i < 10) {
        members.add(
          Text(
              member.id == FirebaseAuth.instance.currentUser.uid
                  ? 'You'
                  : member.name,
              style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor)),
        );
      }

      i += 1;
    }
    return members;
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
