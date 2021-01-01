import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 25.0),
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
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => WebPage(
            //             title: "One Healing Space",
            //             selectedUrl: "https://healingclinic.janeapp.com/")));
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(25.0)),
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            margin: EdgeInsets.fromLTRB(60.0, 20.0, 60.0, 5.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FlutterIcons.calendar_ant,
                      color: Colors.white, size: 17.0),
                  SizedBox(width: 10.0),
                  Text(
                    'Book an appointment',
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        title: Text(
          widget.club.name,
          style: GoogleFonts.questrial(
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).accentColor),
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.7,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.pencil_plus_mco),
            onPressed: () {
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
            },
          ),
          IconButton(
            icon: Icon(AntDesign.team),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OHSMembersPage(
                            members: widget.club.memberList,
                            club: widget.club,
                            isCourse: false,
                          )));
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OHSCalendarPage(
                            club: widget.club,
                          )));
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
                        clubFuture = OneHealingSpace.fetchPosts(sortBy);
                      });
                    },
                    child: Center(
                      child: Text(
                        "Sorting by: ${sortBy == 0 ? 'Recent' : 'You first'}",
                        style: GoogleFonts.questrial(
                          textStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).buttonColor),
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: clubFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
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

                          Function a = () async {
                            var res = await OneHealingSpace.deletePostWithUser(
                                post.id, post.userId, post.university);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                clubFuture = OneHealingSpace.fetchPosts(sortBy);
                              });
                              previewMessage("Post Deleted", context);
                            } else {
                              previewMessage("Error deleting post!", context);
                            }
                          };
                          Function f = () async {
                            var res = await OneHealingSpace.deletePost(post.id);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                clubFuture = OneHealingSpace.fetchPosts(sortBy);
                              });
                              previewMessage("Post Deleted", context);
                            } else {
                              previewMessage("Error deleting post!", context);
                            }
                          };

                          Function b = () async {
                            var res = await block(post.userId, post.university);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                clubFuture = OneHealingSpace.fetchPosts(sortBy);
                              });
                              previewMessage("User blocked.", context);
                            }
                          };

                          Function h = () async {
                            var res = await hidePost(post.id);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                clubFuture = OneHealingSpace.fetchPosts(sortBy);
                              });
                              previewMessage("Post hidden from feed.", context);
                            }
                          };

                          return OHSPostWidget(
                              key: ValueKey(post.id),
                              post: post,
                              timeAgo: timeago.format(timeAgo),
                              club: widget.club,
                              deletePost: f,
                              block: b,
                              hide: h,
                              deleteAsAdmin: a);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.face,
                                color: Theme.of(context).accentColor,
                              ),
                              SizedBox(width: 10),
                              Text("Could not load posts :(",
                                  style: GoogleFonts.questrial(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor),
                                  )),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: LoadingIndicator(
                              indicatorType: Indicator.ballBeat,
                              color: Theme.of(context).accentColor),
                        ),
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
                                color: Theme.of(context).accentColor,
                              ),
                              SizedBox(width: 10),
                              Text("There are no posts :(",
                                  style: GoogleFonts.questrial(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor),
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
    );
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
  }
}
