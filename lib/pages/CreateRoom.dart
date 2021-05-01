import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/room.dart';

class CreateRoom extends StatefulWidget {
  CreateRoom({Key key}) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  int clength = 50;
  int dlength = 300;
  bool isLocked = false;
  Image imag;
  File f;
  bool isPosting = false;
  String title = "Name your room";
  String description = "Describe your room";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        brightness: Theme.of(context).brightness,
        leading: IconButton(
            icon: Icon(FlutterIcons.arrow_back_mdi,
                color: Theme.of(context).accentColor),
            onPressed: () => Navigator.pop(context, false)),
        centerTitle: false,
        title: Text(
          "",
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: body(),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: createButton(),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
      child: ListView(
        children: [
          Center(child: picture()),
          SizedBox(height: 15.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [descriptionField()],
                  ),
                ),
              ),
            ],
          ),
          Divider(
            indent: 0.0,
            color: Colors.grey[400],
          ),
          SizedBox(height: 10.0),
          anonymous()
        ],
      ),
    );
  }

  Widget anonymous() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            this.setState(() {
              isLocked = false;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Unicon(UniconData.uniGlobe,
                            size: 17.0, color: Theme.of(context).accentColor),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Public',
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor)),
                        Text(
                          'Anyone can join this room',
                          style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).buttonColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                  isLocked == true
                      ? FlutterIcons.md_radio_button_off_ion
                      : FlutterIcons.md_radio_button_on_ion,
                  size: 20,
                  color: isLocked == true
                      ? Theme.of(context).buttonColor
                      : Colors.deepPurpleAccent),
            ],
          ),
        ),
        Divider(),
        InkWell(
          onTap: () {
            this.setState(() {
              isLocked = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Unicon(UniconData.uniLock,
                            size: 17.0, color: Theme.of(context).accentColor),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Private',
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor)),
                        Text(
                          'Only invited users can join',
                          style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).buttonColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                  isLocked == false
                      ? FlutterIcons.md_radio_button_off_ion
                      : FlutterIcons.md_radio_button_on_ion,
                  size: 20,
                  color: isLocked == false
                      ? Theme.of(context).buttonColor
                      : Colors.deepPurpleAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget createButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20),
      child: InkWell(
        onTap: () async {
          var first = await isFirstLaunch();
          if (first) {
            return;
          }
          if (nameController.text.isEmpty ||
              descriptionController.text.isEmpty ||
              imag == null ||
              f == null) {
            previewMessage(
                'All fields are required, including an image.', context);
            return;
          }
          if (clength < 0 || dlength < 0) {
            return;
          }
          if (imag != null && f != null) {
            // with image
            setState(() {
              isPosting = true;
            });
            // check for nudity
            var approval = await imageApproved(f);
            if (approval) {
              var res = await post();
              if (res) {
                // sendRoomNotification(
                //     "Someone is talking about '${nameController.text}'. Tap in to discuss!");
                nameController.clear();
                descriptionController.clear();
                Navigator.pop(context, true);
              } else {
                setState(() {
                  isPosting = false;
                });
                previewMessage("Error creating your room!", context);
              }
            } else {
              // show error message
              setState(() {
                isPosting = false;
              });
              previewMessage(
                  "Error! Looks like your image contains sexual content.",
                  context);
            }
          } else {
            // without image
            setState(() {
              isPosting = true;
            });
            var res = await post();
            if (res) {
              // sendRoomNotification(
              //     "Someone is talking about '${nameController.text}'. Tap in to discuss!");
              nameController.clear();
              descriptionController.clear();
              Navigator.pop(context, true);
            } else {
              // show error message
              setState(() {
                isPosting = false;
              });
              previewMessage("Error creating your room!", context);
            }
          }
        },
        child: Hero(
          tag: 'btn3',
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: isPosting
                    ? SizedBox(
                        width: 15,
                        height: 15,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballClipRotateMultiple,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Start Room',
                        style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).backgroundColor),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget picture() {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            var res = await getImage();
            if (res.isNotEmpty) {
              var image = res[0] as Image;
              var file = res[1] as File;
              this.setState(() {
                imag = image;
                f = file;
              });
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: imag != null
                  ? Image(
                      image: imag.image,
                      fit: BoxFit.cover,
                    )
                  : Unicon(UniconData.uniCameraPlus, color: Colors.black),
            ),
          ),
        ),
        Visibility(
          visible: imag != null && f != null,
          child: Positioned(
              top: 6,
              left: 6,
              child: InkWell(
                onTap: () {
                  this.setState(() {
                    imag = null;
                    f = null;
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 10,
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              )),
        ),
      ],
    );
  }

  Widget descriptionField() {
    return Flexible(
      child: Column(
        children: [
          field1(),
          SizedBox(height: 10.0),
          field2(),
        ],
      ),
    );
  }

  Future<bool> post() async {
    setState(() {
      isPosting = true;
    });

    var result = await Room.create(
        name: nameController.text,
        description: descriptionController.text,
        isLocked: isLocked,
        coverImg: imag,
        imgFile: f);

    setState(() {
      clength = 50;
      dlength = 300;
    });
    return result;
  }

  Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var yes = prefs.getBool('isFirst');
    if (yes == null) {
      Constants.termsDialog(context);
      return true;
    } else {
      return false;
    }
  }

  Widget field1() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(5.0)),
      child: TextField(
        controller: nameController,
        textInputAction: TextInputAction.newline,
        maxLines: null,
        onChanged: (value) {
          var newLength = 50 - value.length;
          setState(() {
            clength = newLength;
          });
        },
        decoration: new InputDecoration(
            suffix: Text(
              clength.toString(),
              style: GoogleFonts.quicksand(
                  color: clength < 0 ? Colors.red : Colors.grey),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: title),
        style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
    );
  }

  Widget field2() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(5.0)),
      child: TextField(
        controller: descriptionController,
        textInputAction: TextInputAction.done,
        maxLines: null,
        onChanged: (value) {
          var newLength = 100 - value.length;
          setState(() {
            dlength = newLength;
          });
        },
        decoration: new InputDecoration(
            suffix: Text(
              dlength.toString(),
              style: GoogleFonts.quicksand(
                  color: dlength < 0 ? Colors.red : Colors.grey),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: description),
        style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
  }
}
