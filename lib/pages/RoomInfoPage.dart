import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/AddUserPage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/pages/Rooms.dart';

class RoomInfoPage extends StatefulWidget {
  final Room room;
  RoomInfoPage({Key key, @required this.room}) : super(key: key);
  @override
  _RoomInfoPageState createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController nameEditController = TextEditingController();
  TextEditingController descriptionEditController = TextEditingController();
  bool doneLoading = false;
  bool isEditing = false;
  List<PostUser> members = [];
  File f;
  Image imag;
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        title: Text(widget.room.isAdmin ? 'Manage Room' : 'Room Info',
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                color: Theme.of(context).accentColor)),
        actions: [
          Visibility(
            visible:
                FirebaseAuth.instance.currentUser.uid == widget.room.adminId,
            child: IconButton(
                icon: Unicon(
                  UniconData.uniUserPlus,
                  color: Colors.blue,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddUserPage(room: widget.room))).then((value) {
                    if (value == true) {
                      setState(() {
                        doneLoading = false;
                      });
                      Room.allMembers(room: widget.room).then((value) {
                        setState(() {
                          members = value;
                          doneLoading = true;
                          widget.room.members = value;
                        });
                      });
                    }
                  });
                }),
          ),
          Visibility(
            visible:
                FirebaseAuth.instance.currentUser.uid == widget.room.adminId,
            child: IconButton(
                icon: Unicon(
                  UniconData.uniTrash,
                  color: Colors.red.shade700,
                ),
                onPressed: () {
                  delete();
                }),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Visibility(
              visible: widget.room.inRoom == false &&
                  widget.room.adminId != FirebaseAuth.instance.currentUser.uid,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient:
                          LinearGradient(colors: [Colors.purple, Colors.pink])),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Don't miss out! Join this room.",
                        textAlign: TextAlign.center,
                        maxLines: null,
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text('INFO',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: Theme.of(context).accentColor)),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            if (widget.room.isAdmin) {
                              var res = await getImage();
                              if (res.isNotEmpty) {
                                var image = res[0] as Image;
                                var file = res[1] as File;
                                this.setState(() {
                                  imag = image;
                                  f = file;
                                });
                                savePhoto();
                              }
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: imag != null && f != null
                                ? Image.file(f,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : CachedNetworkImage(
                                    imageUrl: widget.room.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        SizedBox(width: 15.0),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.room.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).accentColor)),
                              Text(
                                  widget.room.description +
                                      widget.room.description,
                                  maxLines: 4,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 13.0,
                                      color: Theme.of(context).buttonColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.room.adminId ==
                      FirebaseAuth.instance.currentUser.uid,
                  child: IconButton(
                    icon: Unicon(UniconData.uniEdit,
                        color: Theme.of(context).accentColor),
                    onPressed: () {
                      startEditing();
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 25.0),
            Text('MEMBERS',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: Theme.of(context).accentColor)),
            SizedBox(height: 20.0),
            doneLoading
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.room.members.length,
                    itemBuilder: (context, index) {
                      PostUser user = widget.room.members[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage(
                                            isFromChat: false,
                                            isFromMain: false,
                                            isMyProfile: user.id ==
                                                FirebaseAuth
                                                    .instance.currentUser.uid,
                                            user: user,
                                            heroTag: user.id)));
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: CachedNetworkImage(
                                        imageUrl: user.profileImgUrl != null
                                            ? user.profileImgUrl
                                            : '',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 15.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            user.id ==
                                                    FirebaseAuth.instance
                                                        .currentUser.uid
                                                ? 'You'
                                                : user.name,
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16.0,
                                                color: Theme.of(context)
                                                    .accentColor)),
                                        Text(
                                            user.about != null &&
                                                    user.about.isNotEmpty
                                                ? user.about
                                                : 'No bio available',
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12.0,
                                                color: Theme.of(context)
                                                    .buttonColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            widget.room.adminId == user.id
                                ? Text('Admin')
                                : widget.room.adminId ==
                                        FirebaseAuth.instance.currentUser.uid
                                    ? IconButton(
                                        icon: Icon(
                                          FlutterIcons.minus_circle_faw,
                                          size: 20.0,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          remove(user: user);
                                        },
                                      )
                                    : Container()
                          ],
                        ),
                      );
                    })
                : SizedBox(
                    width: 30,
                    height: 30,
                    child: LoadingIndicator(
                        indicatorType: Indicator.ballClipRotate,
                        color: Theme.of(context).accentColor)),
            SizedBox(
              height: 20.0,
            ),
            InkWell(
              onTap: () async {
                if (widget.room.inRoom) {
                  Room.leave(roomId: widget.room.id).then((value) {
                    if (value) {
                      setState(() {
                        widget.room.inRoom = false;
                        widget.room.members.removeWhere((element) =>
                            element.id ==
                            FirebaseAuth.instance.currentUser.uid);
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      });
                    }
                  });
                } else {
                  Room.join(roomId: widget.room.id).then((value) async {
                    if (value) {
                      await getUser(FirebaseAuth.instance.currentUser.uid)
                          .then((user) {
                        setState(() {
                          widget.room.inRoom = true;
                          widget.room.members.add(user);
                        });
                      });
                    }
                  });
                }
              },
              child: Text(
                  widget.room.inRoom == false &&
                          widget.room.adminId !=
                              FirebaseAuth.instance.currentUser.uid
                      ? 'Join Room'
                      : widget.room.inRoom
                          ? widget.room.adminId !=
                                  FirebaseAuth.instance.currentUser.uid
                              ? 'Leave Room'
                              : ''
                          : '',
                  style:
                      GoogleFonts.quicksand(fontSize: 13.0, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> update() async {
    bool name = false;
    bool desc = false;
    bool res = false;
    if (nameEditController.text.isEmpty &&
        descriptionEditController.text.isEmpty) {
      return false;
    }
    if (nameEditController.text.isNotEmpty) {
      name = true;
    }
    if (descriptionEditController.text.isNotEmpty) {
      desc = true;
    }

    if (name == true && desc == true) {
      res = await Room.updateInfo(
          roomId: widget.room.id,
          name: nameEditController.text,
          description: descriptionEditController.text);
    } else if (name == true && desc == false) {
      res = await Room.updateInfo(
          roomId: widget.room.id, name: nameEditController.text);
    } else if (name == false && desc == true) {
      res = await Room.updateInfo(
          roomId: widget.room.id, description: descriptionEditController.text);
    }

    return res;
  }

  startEditing() {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.NO_HEADER,
        body: StatefulBuilder(builder: (context, setState) {
          bool updating = false;
          return Flexible(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('* Tap on the image to change it.',
                      style: GoogleFonts.quicksand(
                          fontSize: 10.0,
                          color: Theme.of(context).buttonColor)),
                  SizedBox(height: 10.0),
                  Text('Room name:',
                      style: GoogleFonts.quicksand(fontSize: 13.0)),
                  TextField(
                    controller: nameEditController,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    onChanged: (value) {
                      // var newLength = 300 - value.length;
                      // setState(() {
                      //   clength = newLength;
                      // });
                    },
                    decoration: new InputDecoration(
                        // suffix: Text(
                        //   clength.toString(),
                        //   style: GoogleFonts.quicksand(color: clength < 0 ? Colors.red : Colors.grey),
                        // ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 0, bottom: 11, top: 0, right: 15),
                        hintText: widget.room.name),
                    style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                  Text('Room description:',
                      style: GoogleFonts.quicksand(fontSize: 13.0)),
                  TextField(
                    controller: descriptionEditController,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    onChanged: (value) {
                      // var newLength = 300 - value.length;
                      // setState(() {
                      //   clength = newLength;
                      // });
                    },
                    decoration: new InputDecoration(
                        // suffix: Text(
                        //   clength.toString(),
                        //   style: GoogleFonts.quicksand(color: clength < 0 ? Colors.red : Colors.grey),
                        // ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 0, bottom: 11, top: 0, right: 15),
                        hintText: widget.room.description),
                    style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        updating = true;
                      });
                      var res = await update();
                      if (res) {
                        setState(() {
                          updating = false;
                        });
                        this.setState(() {
                          if (nameEditController.text.isNotEmpty) {
                            widget.room.name = nameEditController.text;
                          }
                          if (descriptionEditController.text.isNotEmpty) {
                            widget.room.description =
                                descriptionEditController.text;
                          }
                        });
                        nameEditController.clear();
                        descriptionEditController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: updating
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballClipRotate,
                                      color: Colors.white))
                              : Text(
                                  'Update',
                                  style: GoogleFonts.quicksand(
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }))
      ..show();
  }

  void savePhoto() {
    final act = CupertinoActionSheet(
        title: Text(
          'Happy?',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        message: Text(
          'Yes. Update New Photo',
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
                Navigator.pop(context);
                Room.updateInfo(imageFile: f, roomId: widget.room.id)
                    .then((value) {
                  setState(() {
                    if (value != false) {
                      widget.room.imageUrl = value;
                    }
                  });
                });
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
                setState(() {
                  imag = null;
                  f = null;
                });
                Navigator.pop(context);
              }),
        ]);
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  void remove({PostUser user}) {
    final act = CupertinoActionSheet(
        title: Text(
          'Delete Room',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        message: Text(
          'Are you sure you want to remove this user?',
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
                var res = await Room.deleteMember(
                    roomId: widget.room.id, memberId: user.id);
                if (res) {
                  pushRemovedFromRoom(
                      room: widget.room, receiverId: user.device_token);
                  setState(() {
                    widget.room.members
                        .removeWhere((element) => element.id == user.id);
                    members.removeWhere((element) => element.id == user.id);
                  });
                }
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
        context: context, builder: (BuildContext context) => act);
  }

  void delete() {
    final act = CupertinoActionSheet(
        title: Text(
          'Delete Room',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        message: Text(
          'Are you sure you want to delete this room? This action cannot be reversed.',
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
                Room.delete(id: widget.room.id).then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
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
        context: context, builder: (BuildContext context) => act);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameEditController.dispose();
    descriptionEditController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Room.allMembers(room: widget.room).then((value) {
      setState(() {
        members = value;
        doneLoading = true;
      });
    });
  }

  bool get wantKeepAlive => true;
}
