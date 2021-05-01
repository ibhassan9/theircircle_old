import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/pages/OHS%20Pages/CalendarPage.dart';
import 'package:unify/pages/OHS%20Pages/MembersPage.dart';
import 'package:unify/pages/OHS%20Pages/OHSPostPage.dart';
import 'package:unify/pages/OHS%20Pages/OHSPostWidget.dart';
import 'package:unify/pages/WebPage.dart';
import 'package:unify/pages/join_requests_list.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/pages/members_list_page.dart';
import 'package:unify/widgets/PostWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/pages/course_calender_page.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/PostPage.dart';

class OHSMainPage extends StatefulWidget {
  final Club club;

  OHSMainPage({Key key, this.club}) : super(key: key);

  @override
  _OHSMainPageState createState() => _OHSMainPageState();
}

class _OHSMainPageState extends State<OHSMainPage> {
  int sortBy = 0;
  Future<List<Post>> clubFuture;
  Gradient gradient = LinearGradient(colors: [Colors.blue, Colors.pink]);
  var iconContainerHeight = 55.00;
  ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.pink,
        bottomNavigationBar: Container(
          color: Theme.of(context).backgroundColor,
          margin: EdgeInsets.only(bottom: 0.0),
          child: InkWell(
            onTap: () {
              showBarModalBottomSheet(
                context: context,
                enableDrag: false,
                expand: true,
                builder: (context) => WebPage(
                    title: "One Healing Space",
                    selectedUrl: "https://healingclinic.janeapp.com/"),
              );
              OneHealingSpace.pushRedirect();
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => WebPage(
              //             title: "One Healing Space",
              //             selectedUrl: "https://healingclinic.janeapp.com/")));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(25.0)),
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              margin: EdgeInsets.fromLTRB(60.0, 5.0, 60.0, 20.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FlutterIcons.calendar_ant,
                        color: Colors.black, size: 17.0),
                    SizedBox(width: 10.0),
                    Text(
                      'Book an appointment',
                      style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).backgroundColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: false,
          titleSpacing: 0.0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.club.name,
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                widget.club.description,
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.pink,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, right: 15.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OHSMembersPage(
                                members: widget.club.memberList,
                                club: widget.club,
                                isCourse: false,
                              )));
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
                      Text(widget.club.memberCount.toString(),
                          style: GoogleFonts.quicksand(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            ),

            // IconButton(
            //   icon: Icon(FlutterIcons.plus_square_o_faw),
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => OHSPostPage(
            //                   club: widget.club,
            //                 ))).then((value) {
            //       if (value == false) {
            //         return;
            //       }
            //       setState(() {
            //         clubFuture = OneHealingSpace.fetchPosts(sortBy);
            //       });
            //     });
            //   },
            // ),
            // IconButton(
            //   icon: Icon(AntDesign.team),
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => OHSMembersPage(
            //                   members: widget.club.memberList,
            //                   club: widget.club,
            //                   isCourse: false,
            //                 )));
            //   },
            // ),
            // IconButton(
            //   icon: ShaderMask(
            //       shaderCallback: (bounds) => gradient.createShader(
            //             Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            //           ),
            //       child: Icon(Icons.calendar_today, color: Colors.white)),
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => OHSCalendarPage(
            //                   club: widget.club,
            //                 )));
            //   },
            // )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CourseCalendarPage(
                                    course: null, club: widget.club)));
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
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                      child: Container(
                        color: Theme.of(context).backgroundColor,
                        child: Column(
                          children: <Widget>[
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
                                          clubFuture =
                                              OneHealingSpace.fetchPosts(
                                                  sortBy);
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
                            SizedBox(height: 5.0),
                            Flexible(
                              child: FutureBuilder(
                                future: clubFuture,
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

                                          Function a = () async {
                                            var res = await OneHealingSpace
                                                .deletePostWithUser(
                                                    post.id,
                                                    post.userId,
                                                    post.university);
                                            Navigator.pop(context);
                                            if (res) {
                                              setState(() {
                                                clubFuture =
                                                    OneHealingSpace.fetchPosts(
                                                        sortBy);
                                              });
                                              previewMessage(
                                                  "Post Deleted", context);
                                            } else {
                                              previewMessage(
                                                  "Error deleting post!",
                                                  context);
                                            }
                                          };
                                          Function f = () async {
                                            var res = await OneHealingSpace
                                                .deletePost(post.id);
                                            Navigator.pop(context);
                                            if (res) {
                                              setState(() {
                                                clubFuture =
                                                    OneHealingSpace.fetchPosts(
                                                        sortBy);
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
                                                post.userId, post.university);
                                            Navigator.pop(context);
                                            if (res) {
                                              setState(() {
                                                clubFuture =
                                                    OneHealingSpace.fetchPosts(
                                                        sortBy);
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
                                                clubFuture =
                                                    OneHealingSpace.fetchPosts(
                                                        sortBy);
                                              });
                                              previewMessage(
                                                  "Post hidden from feed.",
                                                  context);
                                            }
                                          };

                                          return OHSPostWidget(
                                              key: ValueKey(post.id),
                                              post: post,
                                              timeAgo: timeago.format(timeAgo,
                                                  locale: 'en_short'),
                                              club: widget.club,
                                              deletePost: f,
                                              block: b,
                                              hide: h,
                                              deleteAsAdmin: a);
                                        },
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return AnimatedSwitcher(
                                      duration: Duration(seconds: 1),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
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
                                                "Could not load posts :(",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return AnimatedSwitcher(
                                      duration: Duration(seconds: 1),
                                      child: Center(
                                        child: SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: LoadingIndicator(
                                              indicatorType: Indicator
                                                  .ballClipRotateMultiple,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return AnimatedSwitcher(
                                      duration: Duration(seconds: 1),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
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
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
            width: 40,
            height: 40,
            child: FloatingActionButton(
                backgroundColor: Theme.of(context).accentColor.withOpacity(0.7),
                elevation: 0.0,
                child: Unicon(UniconData.uniPlus,
                    color: Theme.of(context).backgroundColor),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OHSPostPage(
                                club: widget.club,
                              ))).then((value) {
                    if (value == false) {
                      return;
                    }
                    setState(() {
                      clubFuture = OneHealingSpace.fetchPosts(sortBy);
                    });
                  });
                })));
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

  Future<Null> refresh() async {
    this.setState(() {
      clubFuture = OneHealingSpace.fetchPosts(sortBy);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clubFuture = OneHealingSpace.fetchPosts(sortBy);
    _controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
