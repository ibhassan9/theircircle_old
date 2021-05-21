import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ConferencePage.dart';
import 'package:unify/pages/ProfilePage.dart';

class SpeakerIcon extends StatefulWidget {
  final Speaker speaker;
  final Room room;
  SpeakerIcon({Key key, this.speaker, this.room}) : super(key: key);
  @override
  _SpeakerIconState createState() => _SpeakerIconState();
}

class _SpeakerIconState extends State<SpeakerIcon> {
  PostUser user;

  Widget build(BuildContext context) {
    return user != null
        ? Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          showBarModalBottomSheet(
                              context: context,
                              builder: (context) => ProfilePage(
                                  user: user,
                                  isFromChat: false,
                                  isMyProfile: user.id ==
                                      FirebaseAuth.instance.currentUser.uid,
                                  isFromMain: false));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInAnimation(
                            child: CachedNetworkImage(
                                imageUrl: user.profileImgUrl != null
                                    ? user.profileImgUrl
                                    : Constants.dummyProfilePicture,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child:
                            widget.speaker.isMuted && !widget.speaker.isAudience
                                ? CircleAvatar(
                                    radius: 10,
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    child: Icon(Icons.mic_off,
                                        size: 15.0,
                                        color: Theme.of(context).accentColor),
                                  )
                                : Container(),
                      ),
                      widget.room.adminId == user.id
                          ? Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.teal),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 3.0,
                                      left: 5.0,
                                      right: 5.0,
                                      bottom: 3.0),
                                  child: Text("MOD",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            )
                          : Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.transparent),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 3.0,
                                      left: 5.0,
                                      right: 5.0,
                                      bottom: 3.0),
                                  child: Container(),
                                ),
                              ),
                            )
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Text(user.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).accentColor,
                      )),
                ],
              ),
            ),
          )
        : Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser(widget.speaker.id).then((value) {
      setState(() {
        user = value;
      });
    });
  }
}
