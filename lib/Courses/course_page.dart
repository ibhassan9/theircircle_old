import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Courses/members_list_page.dart';
import 'package:unify/Home/PostWidget.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Courses/course_calender_page.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;

class CoursePage extends StatefulWidget {
  final Course course;

  CoursePage({Key key, this.course}) : super(key: key);

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController contentController = TextEditingController();

    showAddDialog() {
      Image imag;
      File f;
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create New Post",
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                imag == null
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.image,
                                  color: Colors.grey.shade600),
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
                              },
                            ),
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          child: Container(
                              height: 150, child: Image(image: imag.image)),
                        )),
                TextField(
                  controller: contentController,
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Where is the Davis?"),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          }),
          btnOkColor: Colors.deepPurple,
          btnOkOnPress: () async {
            var post = Post(
              content: contentController.text,
              isAnonymous: false,
            );

            var res = imag == null
                ? await createCoursePost(post, widget.course)
                : await uploadImageToStorage(f);
            // res is a boolean if imag is null - string if image available

            imag != null ? post.imgUrl = res : post.imgUrl = null;

            var result = await createCoursePost(post, widget.course);
            // check if result is true

            setState(() {});
            contentController.clear();
          })
        ..show();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.course.code,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showAddDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MembersListPage(members: widget.course.memberList)));
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CourseCalendarPage(course: widget.course)));
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                future: fetchCoursePosts(widget.course),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          snapshot.data != null ? snapshot.data.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        Post post = snapshot.data[index];
                        var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                            post.timeStamp);
                        return PostWidget(
                            post: post,
                            timeAgo: timeago.format(timeAgo),
                            course: widget.course);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          )
        ],
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 20.0),
      //   child: Container(
      //     height: 50,
      //     child: FlatButton(
      //       color: Colors.deepPurple,
      //       child: Text(
      //         "Create a Poll",
      //         style: GoogleFonts.quicksand(
      //           textStyle: TextStyle(
      //               fontSize: 17,
      //               fontWeight: FontWeight.w700,
      //               color: Colors.white),
      //         ),
      //       ),
      //       onPressed: () {},
      //     ),
      //   ),
      // ),
    );
  }
}
