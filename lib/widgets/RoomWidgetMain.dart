import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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

class _RoomWidgetMainState extends State<RoomWidgetMain>
    with AutomaticKeepAliveClientMixin {
  Color color;

  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 3.0),
      child: InkWell(
        onTap: () async {
          bool live = await Room.isLive(id: widget.room.id);
          if (!live) {
            Constants.roomNA(context);
            return;
          }
          if (widget.room.isLocked == false ||
              widget.room.adminId == FirebaseAuth.instance.currentUser.uid ||
              widget.room.inRoom) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 4,
                              offset: Offset(0, 0), // Shadow position
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            // border: Border.all(
                            //     color: widget.room.inRoom || widget.room.isAdmin
                            //         ? Colors.transparent
                            //         : Colors.transparent,
                            //     width: 2.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  imageUrl: widget.room.imageUrl),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.room.inRoom || widget.room.isAdmin
                    ? Positioned(
                        bottom: 0.0,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).backgroundColor),
                          child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 3.0),
                              child: Icon(FlutterIcons.user_check_fea,
                                  size: 12.0,
                                  color: Theme.of(context).accentColor)),
                        ),
                      )
                    : SizedBox()
              ],
            ),
            SizedBox(height: 5.0),
            Container(
              width: 70,
              child: Center(
                child: Text(widget.room.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        fontSize: 14.0, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
    print(widget.room.inRoom);
  }

  @override
  bool get wantKeepAlive => true;
}
