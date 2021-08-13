import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/PostPage.dart';
import 'package:unify/widgets/CompleteProfileWidget.dart';
import 'package:unify/widgets/CreateRoomButtonMain.dart';
import 'package:unify/widgets/PostWidget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/widgets/RoomWidgetMain.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  StreamController _streamController = StreamController<List<Post>>();
  Future<List<Room>> _roomFuture;
  List<Post> posts = [];
  int r = 0;
  bool loadingMore = false;
  bool doneLoading = true;
  String lastPostID = '';
  int lastPostTimeStamp = 0;
  int sortBy = 0;
  int sortID = 0;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: body(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrangeAccent,
        mini: false,
        child: Unicon(UniconData.uniPlus, color: Colors.white),
        onPressed: () async {
          //await sendNewQuestionToAll();
          showBarModalBottomSheet(
              context: context,
              expand: true,
              builder: (context) => PostPage()).then((refresh) {
            if (refresh == false) {
              return;
            }
            fetchPosts(sortBy).then((value) {
              setState(() {
                posts = value;
              });
            });
          });
        },
      ),
    );
  }

  Widget body() {
    return Visibility(
      visible: doneLoading == true,
      child: LazyLoadScrollView(
        isLoading: loadingMore,
        onEndOfPage: () async {
          setState(() {
            loadingMore = true;
          });
          fetchPosts(sortID,
                  lastPostID: lastPostID, lastPostTimeStamp: lastPostTimeStamp)
              .then((value) {
            setState(() {
              loadingMore = false;
              posts.removeLast();
              posts.addAll(value);
              lastPostID = posts.last.id;
              lastPostTimeStamp = posts.last.timeStamp;
            });
          });
        },
        child: RefreshIndicator(
          onRefresh: getInitialData,
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Live Rooms',
                            style: GoogleFonts.quicksand(
                                height: 0.5,
                                color: Theme.of(context).buttonColor,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 10.0),
                        // Text('Tap in to conversate!',
                        //     style: GoogleFonts.quicksand(
                        //         height: 1,
                        //         color: Theme.of(context).buttonColor,
                        //         fontSize: 14.0,
                        //         fontWeight: FontWeight.w500)),
                      ],
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.deepPurpleAccent,
                    //       borderRadius: BorderRadius.only(
                    //           topLeft: Radius.circular(20.0),
                    //           topRight: Radius.circular(20.0),
                    //           bottomLeft: Radius.circular(20.0))),
                    //   child: Padding(
                    //     padding:
                    //         const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                    //     child: Row(
                    //       children: [
                    //         Icon(FlutterIcons.plus_circle_outline_mco,
                    //             color: Colors.white, size: 15.0),
                    //         SizedBox(width: 5.0),
                    //         Text('Create',
                    //             style: GoogleFonts.quicksand(
                    //                 color: Colors.white,
                    //                 fontSize: 16.0,
                    //                 fontWeight: FontWeight.w600)),
                    //       ],
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              rooms(),
              Container(
                color: Theme.of(context).backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 7.0, 15.0, 7.0),
                  child: Row(
                    children: [
                      Unicon(UniconData.uniSortAmountUp,
                          size: 20.0, color: Colors.grey.shade600),
                      SizedBox(width: 5.0),
                      InkWell(
                        onTap: () {
                          showSortBy();
                        },
                        child: Text(
                          "SORTING BY: ${sortID == 0 ? 'Recent' : sortID == 1 ? 'You first' : sortID == 2 ? 'Polls' : 'Daily Questions Answered'}"
                              .toUpperCase(),
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade600),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Unicon(UniconData.uniArrowDown,
                          size: 20.0, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              postWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget rooms() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Container(
          height: 95,
          child: FutureBuilder(
            future: _roomFuture,
            builder: (context, snap) {
              if (snap.hasData &&
                  snap.connectionState == ConnectionState.done) {
                return AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: snap.data.length,
                      itemBuilder: (context, index) {
                        Function reloadRooms = () {
                          setState(() {
                            _roomFuture = Room.fetchAll();
                          });
                        };
                        // if (index == 0) {
                        //   return AnimatedSwitcher(
                        //     duration: Duration(seconds: 1),
                        //     child:
                        //         CreateRoomButtonMain(reloadRooms: reloadRooms),
                        //   );
                        // } else {
                        Room room = snap.data[index];
                        return AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          child:
                              RoomWidgetMain(room: room, reload: reloadRooms),
                        );
                        // }
                      }),
                );
              } else {
                return AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingIndicator(
                            indicatorType: Indicator.ballRotate,
                            color: Theme.of(context).accentColor)));
              }
            },
          )),
    );
  }

  Widget postWidget() {
    return Padding(
        padding: const EdgeInsets.all(0.0),
        child: AnimatedSwitcher(
          duration: Duration(seconds: 1),
          child: posts.isEmpty
              ? Container()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 5.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == posts.length - 1) {
                      lastPostID = posts.last.id;
                      lastPostTimeStamp = posts.last.timeStamp;
                    }
                    Post post = index > r ? posts[index - 1] : posts[index];
                    Function f = () async {
                      var res = await deletePost(post.id, null, null);
                      Navigator.pop(context);
                      if (res) {
                        fetchPosts(sortBy).then((value) {
                          setState(() {
                            posts = value;
                          });
                        });
                        previewMessage("Post Deleted", context);
                      } else {
                        previewMessage("Error deleting post!", context);
                      }
                    };
                    Function b = () async {
                      var res = await block(post.userId, post.userId);
                      Navigator.pop(context);
                      if (res) {
                        fetchPosts(sortBy).then((value) {
                          setState(() {
                            posts = value;
                          });
                        });
                        previewMessage("User blocked.", context);
                      }
                    };

                    Function h = () async {
                      var res = await hidePost(post.id);
                      Navigator.pop(context);
                      if (res) {
                        fetchPosts(sortBy).then((value) {
                          setState(() {
                            posts = value;
                          });
                        });
                        previewMessage("Post hidden from feed.", context);
                      }
                    };
                    var timeAgo =
                        new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
                    // if (index == r) {
                    //   return user != null
                    //       ? user.about == null ||
                    //               user.about.isEmpty ||
                    //               user.instagramHandle == null ||
                    //               user.instagramHandle.isEmpty ||
                    //               user.snapchatHandle == null ||
                    //               user.snapchatHandle.isEmpty ||
                    //               user.profileImgUrl == null ||
                    //               user.profileImgUrl.isEmpty
                    //           ? CompleteProfileWidget()
                    //           : Container()
                    //       : Container();
                    // } else {
                    return PostWidget(
                        key: ValueKey(post.id),
                        post: post,
                        timeAgo: timeago.format(timeAgo, locale: 'en_short'),
                        deletePost: f,
                        block: b,
                        hide: h);
                    // }
                  },
                ),
        ));
  }

  void showSortBy() {
    showBarModalBottomSheet(
        context: context,
        expand: false,
        builder: (context) => sortingContainer());
  }

  Widget sortingContainer() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Filter By',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  posts.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
                  sortID = 0;
                });
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(Feather.clock, color: Colors.white),
                  SizedBox(width: 10.0),
                  Text(
                    'Recents',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  posts.sort((a, b) => (b.userId == FIR_UID)
                      .toString()
                      .compareTo((a.userId == FIR_UID).toString()));
                  sortID = 1;
                });
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(Feather.user, color: Colors.white),
                  SizedBox(width: 10.0),
                  Text(
                    'Your Posts',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  posts.sort((a, b) => (b.questionOne != null)
                      .toString()
                      .compareTo((a.questionOne != null).toString()));
                  sortID = 2;
                });
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(FlutterIcons.poll_mco, color: Colors.white),
                  SizedBox(width: 10.0),
                  Text(
                    'Polls',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  posts.sort((a, b) => (b.tcQuestion != null)
                      .toString()
                      .compareTo((a.tcQuestion != null).toString()));
                  sortID = 3;
                });
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(FlutterIcons.question_answer_mdi, color: Colors.white),
                  SizedBox(width: 10.0),
                  Text(
                    'Daily Questions Answered',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0)
          ],
        ),
      ),
    );
  }

  rand() {
    Random rnd;
    int min = 0;
    int max = posts.length;
    rnd = new Random();
    r = min + rnd.nextInt(max - min);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _streamController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitialData();
  }

  Future<Null> getInitialData() async {
    await Constants.fm.requestPermission();
    _roomFuture = Room.fetchAll();
    fetchPosts(sortBy).then((value) {
      setState(() {
        posts = value;
        rand();
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
