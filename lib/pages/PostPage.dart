import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:polls/polls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Components/text_field_container.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/ShareFeelingPage.dart';

class PostPage extends StatefulWidget {
  final Club club;
  final Course course;
  final String name;
  final bool intro;

  PostPage({Key key, this.club, this.course, this.name, this.intro = false})
      : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController contentController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController pollOptionOneController = TextEditingController();
  TextEditingController pollOptionTwoController = TextEditingController();

  int clength = 300;
  int titleLength = 100;
  int poll1length = 30;
  int poll2length = 30;
  bool isAnonymous = false;
  Image imag;
  File f;
  bool isPosting = false;
  bool pollVisible = false;
  String pollButtonText = "Poll time? Create one!";
  String title = "What's on your mind?";
  String feeling;

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
          widget.intro ? "Introduce yourself!" : "NEW POST",
          style: GoogleFonts.quicksand(
              fontSize: 13,
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
                    children: [
                      descriptionField(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          tagWidget(),
                          SizedBox(width: 5.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        ShareFeelingPage()).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      feeling = value;
                                    });
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 0.0, 10.0, 0.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .buttonColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        3.0)), //             <--- BoxDecoration here
                                child: feeling != null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(Constants.feelings[feeling],
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 18.0)),
                                          SizedBox(width: 5.0),
                                          Text(
                                            'Feeling $feeling',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('😝',
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 18.0)),
                                          SizedBox(width: 5.0),
                                          Text(
                                            'Share a feeling!',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Visibility(
                            visible: feeling != null,
                            child: InkWell(
                              onTap: () {
                                if (feeling != null) {
                                  setState(() {
                                    feeling = null;
                                  });
                                }
                              },
                              child: Icon(FlutterIcons.x_fea,
                                  size: 20.0,
                                  color: Theme.of(context).accentColor),
                            ),
                          )
                        ],
                      )
                    ],
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
          anonymous(),
          Divider(),
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
            Unicon(UniconData.uniLock,
                size: 17.0, color: Theme.of(context).buttonColor),
            SizedBox(width: 10.0),
            Text(
              'Post Anonymously',
              style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).buttonColor),
            ),
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
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20),
      child: InkWell(
        onTap: () async {
          var first = await isFirstLaunch();
          if (first) {
            return;
          }
          if (contentController.text.isEmpty && feeling == null) {
            return;
          }
          if (pollVisible && pollOptionOneController.text.isEmpty ||
              pollVisible && pollOptionTwoController.text.isEmpty) {
            return;
          }
          if (clength < 0 ||
              poll1length < 0 ||
              poll2length < 0 ||
              titleLength < 0) {
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
                    width: 40,
                    height: 40,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballClipRotate,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'POST',
                    style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
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
        child: Text(
          pollVisible ? '🗳️ Remove Poll' : '🗳️ Create Poll',
          style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
      ),
    );
  }

  Widget descriptionField() {
    return Flexible(
      child: Column(
        children: [
          titleField(),
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
          content: contentController.text.trim().isEmpty && feeling != null
              ? 'Is Feeling $feeling'
              : contentController.text.trim(),
          isAnonymous: isAnonymous,
          questionOne: pollOptionOneController.text,
          questionOneLikeCount: 0,
          questionTwo: pollOptionTwoController.text,
          questionTwoLikeCount: 0);
    } else {
      post = Post(
        content: contentController.text.trim().isEmpty && feeling != null
            ? 'Is Feeling $feeling'
            : contentController.text.trim(),
        isAnonymous: isAnonymous,
      );
    }

    if (feeling != null) {
      post.feeling = feeling;
    }

    if (titleController.text.trim().isNotEmpty) {
      post.title = titleController.text;
    }

    var res = imag == null
        ? widget.course == null && widget.club == null
            ? await createPost(post)
            : widget.club != null
                ? await createClubPost(post, widget.club)
                : await createCoursePost(post, widget.course)
        : await uploadImageToStorage(f);
    // res is a boolean if imag is null - string if image available

    imag != null ? post.imgUrl = res : post.imgUrl = null;

    var result = imag != null
        ? widget.course == null && widget.club == null
            ? await createPost(post)
            : widget.club != null
                ? await createClubPost(post, widget.club)
                : await createCoursePost(post, widget.course)
        : true;

    setState(() {
      clength = 300;
      poll1length = 30;
      poll2length = 30;
      titleLength = 100;
    });
    titleController.clear();
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

  Widget titleField() {
    return TextField(
      controller: titleController,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      onChanged: (value) {
        var newLength = 100 - value.length;
        setState(() {
          titleLength = newLength;
        });
      },
      decoration: new InputDecoration(
          suffix: Text(
            titleLength.toString(),
            style: GoogleFonts.quicksand(
                color: titleLength < 0 ? Colors.red : Colors.grey),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
          hintText: 'Insert short title'),
      style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).accentColor),
    );
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
            style: GoogleFonts.quicksand(
                color: clength < 0 ? Colors.red : Colors.grey),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
          hintText: title),
      style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).accentColor),
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
              style: GoogleFonts.quicksand(
                  color: poll1length < 0 ? Colors.red : Colors.grey),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 0, bottom: 11, top: 0, right: 15),
            hintText: "Insert Option 1..."),
        style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
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
              style: GoogleFonts.quicksand(
                  color: poll2length < 0 ? Colors.red : Colors.grey),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
            hintText: "Insert Option 2..."),
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
    contentController.dispose();
    pollOptionOneController.dispose();
    pollOptionTwoController.dispose();
    titleController.dispose();
  }
}
