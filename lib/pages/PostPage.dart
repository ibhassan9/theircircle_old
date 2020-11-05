import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Components/text_field_container.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';

class PostPage extends StatefulWidget {
  final Club club;
  final Course course;
  final String name;

  PostPage({Key key, this.club, this.course, this.name}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController contentController = TextEditingController();

  int clength = 300;
  bool isAnonymous = false;
  Image imag;
  File f;
  bool isPosting = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        brightness: Brightness.light,
        title: Text(
          "Add New Post",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          imag != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(fit: StackFit.passthrough, children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                            height: 200,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Image(
                                image: imag.image,
                              ),
                            ))),
                    Positioned(
                        top: 6,
                        left: 6,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              imag = null;
                              f = null;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        )),
                  ]),
                )
              : Container(),
          TextField(
            controller: contentController,
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
                  style:
                      TextStyle(color: clength < 0 ? Colors.red : Colors.grey),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "What's on your mind?"),
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: InkWell(
                  onTap: () {
                    if (isAnonymous) {
                      setState(() {
                        isAnonymous = false;
                      });
                    } else {
                      setState(() {
                        isAnonymous = true;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.blue, size: 15.0),
                      SizedBox(width: 5.0),
                      Text(
                        isAnonymous == false
                            ? "Posting as yourself"
                            : "Posting Anonymously",
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                )),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(AntDesign.picture, color: Colors.deepOrange),
                        onPressed: () async {
                          var res = await getImage();
                          if (res.isNotEmpty) {
                            var image = res[0] as Image;
                            var file = res[1] as File;
                            setState(() {
                              imag = image;
                              f = file;
                            });
                          }
                        }),
                    isPosting
                        ? Center(
                            child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.deepOrange),
                            ),
                          ))
                        : IconButton(
                            icon: Icon(AntDesign.arrowright,
                                color: Colors.deepOrange),
                            onPressed: () async {
                              var first = await isFirstLaunch();
                              if (first) {
                                return;
                              }
                              if (contentController.text.isEmpty) {
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
                                    previewMessage(
                                        "Error creating your post!", context);
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
                                  Navigator.pop(context);
                                } else {
                                  // show error message
                                  setState(() {
                                    isPosting = false;
                                  });
                                  previewMessage(
                                      "Error creating your post!", context);
                                }
                              }
                            }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> post() async {
    setState(() {
      isPosting = true;
    });
    var post = Post(
      content: contentController.text,
      isAnonymous: isAnonymous,
    );

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
    });
    contentController.clear();
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
}
