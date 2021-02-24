import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
  Future<List<Post>> courseFuture;
  Color color;
  var iconContainerHeight = 55.00;
  ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color,
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.course.code,
                style: TextStyle(
                    fontFamily: "Futura1",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                widget.course.name,
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          backgroundColor: color,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(AntDesign.plus, color: Colors.white),
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => PostPage(
            //                   course: widget.course,
            //                 ))).then((value) {
            //       if (value == false) {
            //         return;
            //       }
            //       setState(() {
            //         courseFuture = fetchCoursePosts(widget.course, sortBy);
            //       });
            //     });
            //   },
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, right: 15.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MembersListPage(
                            members: widget.course.memberList,
                            isCourse: true,
                            course: widget.course),
                      ));
                },
                child: Container(
                  height: 10,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Feather.users, color: Colors.white, size: 20.0),
                      SizedBox(width: 5.0),
                      Text(widget.course.memberCount.toString(),
                          style: GoogleFonts.quicksand(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            ),
            // IconButton(
            //   icon: Icon(AntDesign.team, color: Colors.white),
            //   onPressed: () {

            //   },
            // ),
            // IconButton(
            //   icon: Icon(AntDesign.calendar, color: Colors.white),
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => CourseCalendarPage(
            //                 course: widget.course, club: null)));
            //   },
            // )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CourseCalendarPage(
                                      course: widget.course, club: null)));
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: iconContainerHeight,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Visibility(
                            visible: iconContainerHeight != 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(AntDesign.calendar,
                                    color: Colors.white, size: 20.0),
                                SizedBox(width: 5.0),
                                Text('View Shared Calendar',
                                    style: GoogleFonts.quicksand(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                          ),
                          child: Column(
                            children: [
                              Container(
                                color: Theme.of(context).dividerColor,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 7.0, 15.0, 7.0),
                                  child: Row(
                                    children: [
                                      Unicon(UniconData.uniSortAmountUp,
                                          size: 20.0,
                                          color: Colors.grey.shade600),
                                      SizedBox(width: 5.0),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (sortBy == 0) {
                                              sortBy = 1;
                                            } else {
                                              sortBy = 0;
                                            }
                                            courseFuture = fetchCoursePosts(
                                                widget.course, sortBy);
                                          });
                                        },
                                        child: Text(
                                          "Showing: ${sortBy == 0 ? 'Recent' : 'You first'}"
                                              .toUpperCase(),
                                          style: GoogleFonts.quicksand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.grey.shade600),
                                        ),
                                      ),
                                      SizedBox(width: 5.0),
                                      Unicon(UniconData.uniArrowDown,
                                          size: 20.0,
                                          color: Colors.grey.shade600),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              FutureBuilder(
                                future: courseFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    return AnimatedSwitcher(
                                      duration: Duration(seconds: 1),
                                      child: ListView.builder(
                                        controller: _controller,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        itemCount: snapshot.data != null
                                            ? snapshot.data.length
                                            : 0,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          Post post = snapshot.data[index];
                                          var timeAgo = new DateTime
                                                  .fromMillisecondsSinceEpoch(
                                              post.timeStamp);
                                          Function f = () async {
                                            var res = await deletePost(
                                                post.id, widget.course, null);
                                            Navigator.pop(context);
                                            if (res) {
                                              setState(() {
                                                courseFuture = fetchCoursePosts(
                                                    widget.course, sortBy);
                                              });
                                              previewMessage(
                                                  "Post Deleted", context);
                                            } else {
                                              previewMessage(
                                                  "Error deleting post!",
                                                  context);
                                            }
                                          };
                                          Function b = () async {
                                            var res = await block(
                                                post.userId, post.userId);
                                            Navigator.pop(context);
                                            if (res) {
                                              setState(() {
                                                courseFuture = fetchCoursePosts(
                                                    widget.course, sortBy);
                                              });
                                              previewMessage(
                                                  "User blocked.", context);
                                            }
                                          };

                                          Function h = () async {
                                            var res = await hidePost(post.id);
                                            Navigator.pop(context);
                                            if (res) {
                                              setState(() {
                                                courseFuture = fetchCoursePosts(
                                                    widget.course, sortBy);
                                              });
                                              previewMessage(
                                                  "Post hidden from feed.",
                                                  context);
                                            }
                                          };
                                          return PostWidget(
                                              key: ValueKey(post.id),
                                              post: post,
                                              timeAgo: timeago.format(timeAgo,
                                                  locale: 'en_short'),
                                              course: widget.course,
                                              deletePost: f,
                                              block: b,
                                              hide: h);
                                        },
                                      ),
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return AnimatedSwitcher(
                                      duration: Duration(seconds: 1),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: LoadingIndicator(
                                            indicatorType:
                                                Indicator.ballClipRotate,
                                            color:
                                                Theme.of(context).accentColor,
                                          )),
                                    );
                                  } else {
                                    return AnimatedSwitcher(
                                        duration: Duration(seconds: 1),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.4,
                                          child: Center(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.face,
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "There are no posts :(",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
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
        //         style: GoogleFonts.lexendDeca(
        //           GoogleFonts.quicksand: GoogleFonts.quicksand(
        //               fontSize: 17,
        //               fontWeight: FontWeight.w700,
        //               color: Colors.white),
        //         ),
        //       ),
        //       onPressed: () {},
        //     ),
        //   ),
        // ),
        floatingActionButton: Container(
            width: 40,
            height: 40,
            child: FloatingActionButton(
                backgroundColor: color,
                elevation: 0.0,
                child: Unicon(UniconData.uniPlus, color: Colors.white),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostPage(
                                course: widget.course,
                              ))).then((value) {
                    if (value == false) {
                      return;
                    }
                    setState(() {
                      courseFuture = fetchCoursePosts(widget.course, sortBy);
                    });
                  });
                })));
  }

  Future<Null> refresh() async {
    this.setState(() {
      courseFuture = fetchCoursePosts(widget.course, sortBy);
    });
  }

  void _scrollListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0)
        setState(() {
          iconContainerHeight = 0;
        });
    }
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      if (iconContainerHeight == 0)
        setState(() {
          iconContainerHeight = 55;
        });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    courseFuture = fetchCoursePosts(widget.course, sortBy);
    color = Constants.color();
    _controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.removeListener(_scrollListener);
    _controller.dispose();
  }
}
