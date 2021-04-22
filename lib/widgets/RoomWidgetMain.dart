import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/pages/RoomPage.dart';

class RoomWidgetMain extends StatefulWidget {
  final Room room;
  final Function reload;
  RoomWidgetMain({Key key, this.room, this.reload}) : super(key: key);
  @override
  _RoomWidgetMainState createState() => _RoomWidgetMainState();
}

class _RoomWidgetMainState extends State<RoomWidgetMain> {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: InkWell(
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
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 4,
                        offset: Offset(0, 0), // Shadow position
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        imageUrl: widget.room.imageUrl),
                  ),
                ),
                widget.room.inRoom
                    ? Positioned(
                        top: 0.0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 7.0,
                          backgroundColor: Theme.of(context).backgroundColor,
                          child: SizedBox(
                              height: 30,
                              width: 30,
                              child: LoadingIndicator(
                                  indicatorType: Indicator.ballScaleMultiple,
                                  color: Colors.deepOrangeAccent)),
                        ),
                      )
                    : SizedBox()
              ],
            ),
            SizedBox(height: 5.0),
            Container(
              width: 60,
              child: Center(
                child: Text(widget.room.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                        fontSize: 12.0, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
