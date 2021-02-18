import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

class UserPage extends StatefulWidget {
  String userId;
  UserPage({Key key, this.userId}) : super(key: key);
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController bioController = TextEditingController();
  Image imag;
  File f;
  PostUser user;
  bool object_avail = false;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Profile",
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          brightness: Brightness.light),
      body: object_avail
          ? Stack(
              children: [
                ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                            child: Icon(FlutterIcons.linkedin_faw,
                                color: Colors.blue)),
                        InkWell(
                            child: Icon(FlutterIcons.instagram_faw,
                                color: Colors.purple)),
                        InkWell(
                            child: Icon(FlutterIcons.snapchat_ghost_faw,
                                color: Colors.black)),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    user.profileImgUrl == null
                        ? widget.userId == null
                            ? CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 50.0,
                                child: InkWell(
                                    onTap: () async {
                                      var res = await getImage();
                                      if (res.isNotEmpty) {
                                        var image = res[0] as Image;
                                        var file = res[1] as File;
                                        setState(() {
                                          imag = image;
                                          f = file;
                                        });
                                      }
                                    },
                                    child: Icon(FlutterIcons.picture_ant,
                                        color: Colors.white)))
                            : CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 50.0,
                                child: Icon(FlutterIcons.user_ant,
                                    color: Colors.white))
                        : Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade300,
                              ),
                              child: Image.network(
                                user.profileImgUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.grey.shade600),
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                    SizedBox(height: 10.0),
                    Center(
                        child: Text(
                      user.name,
                      style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    )),
                    SizedBox(height: 5.0),
                    Center(
                        child: user.id == firebaseAuth.currentUser.uid
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: TextField(
                                  controller: bioController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText:
                                        user.bio == null || user.bio.isEmpty
                                            ? Constants.dummyDescription
                                            : user.bio,
                                    hintStyle: GoogleFonts.quicksand(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700),
                                  ),
                                  maxLines: null,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700),
                                ),
                              )
                            : Text(
                                user.bio,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              )),
                    SizedBox(height: 5.0),
                    Divider(),
                    SizedBox(height: 10.0),
                    // Visibility(
                    //   visible: user.id == firebaseAuth.currentUser.uid,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(
                    //         left: 10.0, right: 10.0, top: 15.0),
                    //     child: InkWell(
                    //       onTap: () async {
                    //         await update();
                    //       },
                    //       child: Container(
                    //         height: 40,
                    //         decoration: BoxDecoration(
                    //             color: Colors.purple,
                    //             borderRadius: BorderRadius.circular(5.0)),
                    //         child: Center(
                    //           child: Text(
                    //             "Update Profile",
                    //             style: GoogleFonts.poppins(
                    //               GoogleFonts.quicksand: GoogleFonts.quicksand(
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.w500,
                    //                   color: Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                )
              ],
            )
          : Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Future<Null> update() async {
  //   if (imag == null) {
  //     // just update bio
  //     var res = user.bio != bioController.text
  //         ? await updateProfile(null, bioController.text)
  //         : false;
  //     if (res) {
  //       setState(() {});
  //     }
  //   } else {
  //     // image available, upload image
  //     var url = await uploadImageToStorage(f);
  //     var res = await updateProfile(url, bioController.text);
  //     if (res) {
  //       setState(() {});
  //     }
  //   }
  // }

  Future<Null> getUserData() async {
    PostUser _user = widget.userId == null
        ? await getUser(firebaseAuth.currentUser.uid)
        : await getUser(widget.userId);
    setState(() {
      user = _user;
      object_avail = true;
    });
  }
}
