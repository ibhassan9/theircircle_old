import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:polls/polls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Components/text_field_container.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';

class OHSPostPage extends StatefulWidget {
  final Club club;

  OHSPostPage({Key key, this.club}) : super(key: key);

  @override
  _OHSPostPageState createState() => _OHSPostPageState();
}

class _OHSPostPageState extends State<OHSPostPage> {
  TextEditingController contentController = TextEditingController();
  TextEditingController pollOptionOneController = TextEditingController();
  TextEditingController pollOptionTwoController = TextEditingController();

  int clength = 300;
  int poll1length = 30;
  int poll2length = 30;
  bool isAnonymous = false;
  Image imag;
  File f;
  bool isPosting = false;
  bool pollVisible = false;
  String pollButtonText = "Poll time? Create one!";
  String title = "What's on your mind?";

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
        title: Text(
          "NEW POST",
          style: GoogleFonts.questrial(
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      // body: ListView(
      //   children: [
      // imag != null
      //     ? Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Stack(fit: StackFit.passthrough, children: [
      //           ClipRRect(
      //               borderRadius: BorderRadius.circular(5.0),
      //               child: Container(
      //                   height: 200,
      //                   child: FittedBox(
      //                     fit: BoxFit.cover,
      //                     child: Image(
      //                       image: imag.image,
      //                     ),
      //                   ))),
      //           Positioned(
      //               top: 6,
      //               left: 6,
      //               child: InkWell(
      //                 onTap: () {
      //                   setState(() {
      //                     imag = null;
      //                     f = null;
      //                   });
      //                 },
      //                 child: CircleAvatar(
      //                   backgroundColor: Colors.white,
      //                   child: Icon(
      //                     Icons.close,
      //                     color: Colors.black,
      //                   ),
      //                 ),
      //               )),
      //         ]),
      //       )
      //     : Container(),
      // Divider(),
      // Padding(
      //   padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Container(
      //           child: InkWell(
      //         onTap: () {
      //           if (isAnonymous) {
      //             setState(() {
      //               isAnonymous = false;
      //             });
      //           } else {
      //             setState(() {
      //               isAnonymous = true;
      //             });
      //           }
      //         },
      //         child: Row(
      //           children: [
      //             Icon(Icons.lock, color: Colors.blue, size: 15.0),
      //             SizedBox(width: 5.0),
      //             Text(
      //               isAnonymous == false
      //                   ? "Posting as yourself"
      //                   : "Posting Anonymously",
      //               style: GoogleFonts.questrial(
      //                 textStyle: TextStyle(
      //                     fontSize: 13,
      //                     fontWeight: FontWeight.w500,
      //                     color: Colors.blue),
      //               ),
      //             ),
      //           ],
      //         ),
      //       )),
      //       Row(
      //         children: [
      //           IconButton(
      //               icon: Icon(AntDesign.picture, color: Colors.deepPurple),
      //               onPressed: () async {
      //                 var res = await getImage();
      //                 if (res.isNotEmpty) {
      //                   var image = res[0] as Image;
      //                   var file = res[1] as File;
      //                   setState(() {
      //                     imag = image;
      //                     f = file;
      //                   });
      //                 }
      //               }),
      //           isPosting
      //               ? Center(
      //                   child: SizedBox(
      //                   height: 20,
      //                   width: 20,
      //                   child: CircularProgressIndicator(
      //                     strokeWidth: 3.0,
      //                     valueColor: new AlwaysStoppedAnimation<Color>(
      //                         Colors.deepPurple),
      //                   ),
      //                 ))
      //               : IconButton(
      //                   icon: Icon(AntDesign.arrowright,
      //                       color: Colors.deepPurple),
      //                   onPressed: () async {}),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      //   child: InkWell(
      //     onTap: () {
      //       if (pollVisible) {
      //         setState(() {
      //           pollVisible = false;
      //           pollButtonText = "Poll time? Create one!";
      //           title = "What's on your mind?";
      //         });
      //       } else {
      //         setState(() {
      //           pollVisible = true;
      //           pollButtonText = "Remove Poll";
      //           title = "Insert Poll Title...";
      //         });
      //       }
      //     },
      //     child: Container(
      //       height: 50.0,
      //       color: Colors.deepPurpleAccent,
      //       child: Center(
      //         child: Text(
      //           pollButtonText,
      //           style: GoogleFonts.questrial(
      //             textStyle: TextStyle(
      //                 fontSize: 13,
      //                 fontWeight: FontWeight.w700,
      //                 color: Colors.white),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      //   ],
      // ),
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
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
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
                    children: [descriptionField(), tagWidget()],
                  ),
                ),
              ),
              picture()
            ],
          ),
          SizedBox(height: 5.0),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            child: Row(
          children: [
            Icon(Icons.lock, size: 17.0, color: Theme.of(context).buttonColor),
            SizedBox(width: 10.0),
            Text('Post Anonymously',
                style: GoogleFonts.questrial(
                  textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).buttonColor),
                )),
          ],
        )),
        InkWell(
          onTap: () {
            if (isAnonymous) {
              this.setState(() {
                isAnonymous = false;
              });
            } else {
              this.setState(() {
                isAnonymous = true;
              });
            }
          },
          child: Icon(
              isAnonymous == false
                  ? FlutterIcons.md_radio_button_off_ion
                  : FlutterIcons.md_radio_button_on_ion,
              size: 20,
              color: isAnonymous == false
                  ? Theme.of(context).buttonColor
                  : Colors.deepPurpleAccent),
        ),
      ],
    );
  }

  Widget createButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          10.0, 10.0, 10.0, kBottomNavigationBarHeight),
      child: InkWell(
        onTap: () async {
          var first = await isFirstLaunch();
          if (first) {
            return;
          }
          if (contentController.text.isEmpty) {
            return;
          }
          if (pollVisible && pollOptionOneController.text.isEmpty ||
              pollVisible && pollOptionTwoController.text.isEmpty) {
            return;
          }
          if (clength < 0 || poll1length < 0 || poll2length < 0) {
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
                Navigator.pop(context);
              } else {
                setState(() {
                  isPosting = false;
                });
                previewMessage("Error creating your post!", context);
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
              Navigator.pop(context, true);
            } else {
              // show error message
              setState(() {
                isPosting = false;
              });
              previewMessage("Error creating your post!", context);
            }
          }
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: isPosting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Text('CREATE',
                    style: GoogleFonts.questrial(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    )),
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
            borderRadius: BorderRadius.circular(3.0),
            child: Container(
              height: 100.0,
              width: 85.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: imag != null
                  ? Image(
                      image: imag.image,
                      fit: BoxFit.cover,
                    )
                  : Icon(FlutterIcons.camera_image_mco),
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

  Widget tagWidget() {
    return InkWell(
      onTap: () {
        setState(() {
          if (pollVisible) {
            pollVisible = false;
          } else {
            pollVisible = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[500], width: 0.3),
            borderRadius: BorderRadius.circular(
                3.0)), //             <--- BoxDecoration here
        child: Text(pollVisible ? '🗳️ Remove Poll' : '🗳️ Create Poll',
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            )),
      ),
    );
  }

  Widget descriptionField() {
    return Flexible(
      child: Column(
        children: [
          field1(),
          Divider(),
          field2(),
          field3(),
          Divider(),
        ],
      ),
    );
  }

  Future<bool> post() async {
    setState(() {
      isPosting = true;
    });

    Post post;
    if (pollVisible) {
      post = Post(
          content: contentController.text,
          isAnonymous: isAnonymous,
          questionOne: pollOptionOneController.text,
          questionOneLikeCount: 0,
          questionTwo: pollOptionTwoController.text,
          questionTwoLikeCount: 0);
    } else {
      post = Post(
        content: contentController.text,
        isAnonymous: isAnonymous,
      );
    }

    var res = imag == null
        ? await OneHealingSpace.createPost(post)
        : await uploadImageToStorage(f);
    // res is a boolean if imag is null - string if image available

    imag != null ? post.imgUrl = res : post.imgUrl = null;

    var result = imag != null ? await OneHealingSpace.createPost(post) : true;

    setState(() {
      clength = 300;
      poll1length = 30;
      poll2length = 30;
    });
    contentController.clear();
    pollOptionOneController.clear();
    pollOptionTwoController.clear();
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
    return TextField(
      controller: contentController,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      onChanged: (value) {
        var newLength = 300 - value.length;
        setState(() {
          clength = newLength;
        });
      },
      decoration: new InputDecoration(
          suffix: Text(
            clength.toString(),
            style: TextStyle(color: clength < 0 ? Colors.red : Colors.grey),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
          hintText: title),
      style: GoogleFonts.questrial(
        textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).accentColor),
      ),
    );
  }

  Widget field2() {
    return Visibility(
      visible: pollVisible,
      child: TextField(
        controller: pollOptionOneController,
        textInputAction: TextInputAction.done,
        maxLines: null,
        onChanged: (value) {
          var newLength = 30 - value.length;
          setState(() {
            poll1length = newLength;
          });
        },
        decoration: new InputDecoration(
            suffix: Text(
              poll1length.toString(),
              style:
                  TextStyle(color: poll1length < 0 ? Colors.red : Colors.grey),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
            hintText: "Insert Option 1..."),
        style: GoogleFonts.questrial(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).accentColor),
        ),
      ),
    );
  }

  Widget field3() {
    return Visibility(
      visible: pollVisible,
      child: TextField(
        controller: pollOptionTwoController,
        textInputAction: TextInputAction.done,
        maxLines: null,
        onChanged: (value) {
          var newLength = 30 - value.length;
          setState(() {
            poll2length = newLength;
          });
        },
        decoration: new InputDecoration(
            suffix: Text(
              poll2length.toString(),
              style:
                  TextStyle(color: poll2length < 0 ? Colors.red : Colors.grey),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
            hintText: "Insert Option 2..."),
        style: GoogleFonts.questrial(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).accentColor),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    contentController.dispose();
    pollOptionOneController.dispose();
    pollOptionTwoController.dispose();
  }
}
