import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/pages/members_list_page.dart';
import 'package:unify/widgets/PostWidget.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/pages/course_calender_page.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/PostPage.dart';

class CoursePage extends StatefulWidget {
  final Course course;

  CoursePage({Key key, this.course}) : super(key: key);

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  int sortBy = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.course.id);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          widget.course.code,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.7,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(AntDesign.plus),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostPage(
                            course: widget.course,
                          ))).then((value) {
                setState(() {});
              });
            },
          ),
          IconButton(
            icon: Icon(AntDesign.team),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MembersListPage(
                        members: widget.course.memberList,
                        isCourse: true,
                        course: widget.course),
                  ));
            },
          ),
          IconButton(
            icon: Icon(AntDesign.calendar),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CourseCalendarPage(
                          course: widget.course, club: null)));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (sortBy == 0) {
                          sortBy = 1;
                        } else {
                          sortBy = 0;
                        }
                      });
                    },
                    child: Center(
                      child: Text(
                        "Sorting by: ${sortBy == 0 ? 'Recent' : 'You first'}",
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: fetchCoursePosts(widget.course, sortBy),
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
                          Function f = () async {
                            var res =
                                await deletePost(post.id, widget.course, null);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {});
                              previewMessage("Post Deleted", context);
                            } else {
                              previewMessage("Error deleting post!", context);
                            }
                          };
                          Function b = () async {
                            var res = await block(post.userId);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {});
                              previewMessage("User blocked.", context);
                            }
                          };

                          Function h = () async {
                            var res = await hidePost(post.id);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {});
                              previewMessage("Post hidden from feed.", context);
                            }
                          };
                          return PostWidget(
                              post: post,
                              timeAgo: timeago.format(timeAgo),
                              course: widget.course,
                              deletePost: f,
                              block: b,
                              hide: h);
                        },
                      );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.face,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 10),
                              Text("There are no posts :(",
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
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

  Future<Null> refresh() async {
    this.setState(() {});
  }
}