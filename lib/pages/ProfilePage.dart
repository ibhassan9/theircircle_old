import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart' as p;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/pages/MainPage.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/widgets/PostWidget.dart';

class ProfilePage extends StatefulWidget {
  final PostUser user;
  final String heroTag;
  final bool isFromChat;
  final bool isMyProfile;
  final bool isFromMain;

  ProfilePage(
      {Key key,
      this.user,
      this.heroTag,
      this.isFromChat,
      this.isMyProfile,
      this.isFromMain})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  bool isBlocked;
  Future<List<p.Post>> postsFuture;
  Future<List<p.Video>> videosFuture;
  PostUser user;
  PageController _controller = PageController();

  int selectedOption = 0;
  int likeCount = 0;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '',
          style: GoogleFonts.quicksand(
              fontSize: 25,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        leading: widget.isFromMain != null && widget.isFromMain
            ? null
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(FlutterIcons.arrow_back_mdi,
                    color: Theme.of(context).accentColor)),
        actions: [
          widget.isMyProfile != null
              ? widget.isMyProfile
                  ? IconButton(
                      icon: Icon(AntDesign.logout,
                          color: Theme.of(context).accentColor),
                      onPressed: () async {
                        callLogout();
                      },
                    )
                  : InkWell(
                      onTap: () {
                        isBlocked
                            ? unblock(widget.user.id)
                            : block(widget.user.id, widget.user.university);
                        setState(() {
                          isBlocked = isBlocked ? false : true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(2.0)),
                        width: 75,
                        height: 20,
                        child: Center(
                          child: Text(
                            isBlocked ? "Unblock" : "Block",
                            style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ),
                    )
              : InkWell(
                  onTap: () {
                    isBlocked
                        ? unblock(widget.user.id)
                        : block(widget.user.id, widget.user.university);
                    setState(() {
                      isBlocked = isBlocked ? false : true;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(2.0)),
                        child: Center(
                          child: Text(
                            isBlocked ? "Unblock" : "Block",
                            style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0)),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).backgroundColor,
          child: ListView(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    body(),
                    Flexible(
                      child: PageView(
                        onPageChanged: (index) {
                          setState(() {
                            selectedOption = index;
                          });
                        },
                        controller: _controller,
                        children: [userPosts(), userVideos(), interests()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // body: ListView(
      //     physics: AlwaysScrollableScrollPhysics(),
      //     shrinkWrap: true,
      //     children: [Center(child: picture()), body()])
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          picture(),
          SizedBox(height: 10.0),
          Text(
            user.name,
            style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.university == "UofT"
                    ? "University of Toronto"
                    : widget.user.university == "YorkU"
                        ? "York University"
                        : "Western University",
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).buttonColor),
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                sameUniversity() &&
                        user.id != p.firebaseAuth.currentUser.uid &&
                        widget.isFromChat != null &&
                        widget.isFromChat == false
                    ? InkWell(
                        onTap: () {
                          goToChat();
                        },
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[300], width: 0.5)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 0.0, 10.0, 0.0),
                              child: Text(
                                'Message',
                                style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).buttonColor),
                              ),
                            ),
                          ),
                        ))
                    : widget.isMyProfile != null && widget.isMyProfile
                        ? InkWell(
                            onTap: () async {
                              showBarModalBottomSheet(
                                      context: context,
                                      expand: true,
                                      builder: (context) => MyProfilePage(
                                          user: user, heroTag: widget.heroTag))
                                  .then((value) async {
                                PostUser _u = await getUserWithUniversity(
                                    widget.user.id, widget.user.university);
                                setState(() {
                                  user = _u;
                                });
                              });
                            },
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey[300], width: 0.5)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 10.0, 0.0),
                                  child: Text(
                                    'Edit Profile',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                              ),
                            ))
                        : Container(),
                sameUniversity() ? SizedBox(width: 5.0) : Container(),
                InkWell(
                    onTap: () {
                      if (user.instagramHandle != null &&
                          user.instagramHandle.isNotEmpty) {
                        showHandle(text: user.instagramHandle);
                      } else {
                        Toast.show('Instagram not available', context);
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey[300], width: 0.5)),
                      child: Unicon(UniconData.uniInstagram,
                          color: Theme.of(context).accentColor),
                    )),
                SizedBox(
                  width: 5.0,
                ),
                InkWell(
                    onTap: () {
                      if (user.linkedinHandle != null &&
                          user.linkedinHandle.isNotEmpty) {
                        showHandle(text: user.linkedinHandle);
                      } else {
                        Toast.show('LinkedIn not available', context);
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey[300], width: 0.5)),
                      child: Icon(FlutterIcons.linkedin_box_mco,
                          color: Theme.of(context).accentColor),
                    )),
                SizedBox(
                  width: 5.0,
                ),
                InkWell(
                  onTap: () {
                    if (user.snapchatHandle != null &&
                        user.snapchatHandle.isNotEmpty) {
                      showHandle(text: user.snapchatHandle);
                    } else {
                      Toast.show('Snapchat not available', context);
                    }
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey[300], width: 0.5)),
                    child: Unicon(UniconData.uniSnapchatGhost,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          about(),
          SizedBox(height: 20.0),
          //interests(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    selectedOption = 0;
                  });
                  _controller.animateToPage(0,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeIn);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "POSTS",
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: selectedOption == 0
                              ? Colors.pink
                              : Theme.of(context).accentColor),
                    ),
                    SizedBox(height: 5.0),
                    selectedOption == 0
                        ? Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.pink),
                          )
                        : Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.transparent),
                          )
                  ],
                ),
              ),
              SizedBox(width: 15.0),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedOption = 1;
                  });
                  _controller.animateToPage(1,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeIn);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "VIDEOS",
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: selectedOption == 1
                              ? Colors.pink
                              : Theme.of(context).accentColor),
                    ),
                    SizedBox(height: 5.0),
                    selectedOption == 1
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.pink),
                            width: 5,
                            height: 5,
                          )
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.transparent),
                            width: 5,
                            height: 5,
                          )
                  ],
                ),
              ),
              SizedBox(width: 15.0),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedOption = 2;
                  });
                  _controller.animateToPage(2,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeIn);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "INTERESTS",
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: selectedOption == 2
                              ? Colors.pink
                              : Theme.of(context).accentColor),
                    ),
                    SizedBox(height: 5.0),
                    selectedOption == 2
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.pink),
                            width: 5,
                            height: 5,
                          )
                        : Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.transparent),
                          )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10.0)
          // ListView(
          //   physics: NeverScrollableScrollPhysics(),
          //   scrollDirection: Axis.vertical,
          //   shrinkWrap: true,
          //   children: [userVideos(), userPosts()],
          // )
        ],
      ),
    );
  }

  Widget userVideos() {
    return FutureBuilder(
      future: videosFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  width: 40,
                  height: 40,
                  child: LoadingIndicator(
                    indicatorType: Indicator.circleStrokeSpin,
                    color: Theme.of(context).accentColor,
                  )));
        } else if (snap.hasData && snap.data.length > 0) {
          return Container(
            margin: EdgeInsets.only(left: 5.0, right: 5.0),
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.width / 2,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 2 / 3),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: snap.data != null ? snap.data.length : 0,
              itemBuilder: (BuildContext context, int index) {
                p.Video video = snap.data[index];
                return Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width / 3.1,
                        height: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                            color: Colors.grey[300]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0.0),
                          child: InkWell(
                            onTap: () {
                              var timeAgo =
                                  new DateTime.fromMillisecondsSinceEpoch(
                                      video.timeStamp);
                              Function delete = () async {
                                await p.VideoApi.delete(video.id).then((value) {
                                  //refreshList();
                                });
                              };
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoPreview(
                                          video: video,
                                          timeAgo: timeago.format(timeAgo),
                                          delete: delete)));
                            },
                            child: CachedNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          );
        } else if (snap.hasError) {
          return Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FlutterIcons.sad_cry_faw5,
                  color: Theme.of(context).accentColor,
                  size: 17.0,
                ),
                SizedBox(width: 10),
                Text(
                  "Cannot find any videos :(",
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FlutterIcons.sad_cry_faw5,
                  color: Theme.of(context).accentColor,
                  size: 17.0,
                ),
                SizedBox(width: 10),
                Text(
                  "Cannot find any videos :(",
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget userPosts() {
    return FutureBuilder(
        future: postsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: LoadingIndicator(
                      indicatorType: Indicator.circleStrokeSpin,
                      color: Theme.of(context).accentColor,
                    )));
          } else if (snap.hasData && snap.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: snap.data != null ? snap.data.length : 0,
              itemBuilder: (BuildContext context, int index) {
                p.Post post = snap.data[index];
                Function f = () async {
                  var res = await p.deletePost(post.id, null, null);
                  if (post.type != null) {
                    switch (post.type) {
                      case 'post':
                        res = await p.deletePost(post.id, null, null);
                        break;
                      case 'club':
                        res = await p.deletePost(
                            post.id, null, Club(id: post.typeId));
                        break;
                      case 'course':
                        res = await p.deletePost(
                            post.id, Course(id: post.typeId), null);
                        break;
                      case 'onehealingspace':
                        res = await OneHealingSpace.deletePost(post.id);
                        break;
                      default:
                        res = await p.deletePost(post.id, null, null);
                        break;
                    }
                  } else {
                    res = await p.deletePost(post.id, null, null);
                  }
                  Navigator.pop(context);
                  if (res) {
                    setState(() {
                      postsFuture = p.fetchUserPost(widget.user);
                    });
                    p.previewMessage("Post Deleted", context);
                  } else {
                    p.previewMessage("Error deleting post!", context);
                  }
                };
                Function b = () async {
                  var res = await block(post.userId, post.userId);
                  Navigator.pop(context);
                  if (res) {
                    setState(() {
                      postsFuture = p.fetchUserPost(widget.user);
                    });
                    p.previewMessage("User blocked.", context);
                  }
                };

                Function h = () async {
                  var res = await p.hidePost(post.id);
                  Navigator.pop(context);
                  if (res) {
                    setState(() {
                      postsFuture = p.fetchUserPost(widget.user);
                    });
                    p.previewMessage("Post hidden from feed.", context);
                  }
                };
                var timeAgo =
                    new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
                return PostWidget(
                    key: ValueKey(post.id),
                    post: post,
                    timeAgo: timeago.format(timeAgo, locale: 'en_short'),
                    deletePost: f,
                    block: b,
                    hide: h);
              },
            );
          } else if (snap.hasError) {
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    sameUniversity() ? FlutterIcons.sad_cry_faw5 : Icons.lock,
                    color: Theme.of(context).accentColor,
                    size: 17.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    sameUniversity()
                        ? "Cannot find any posts :("
                        : "You cannot view posts from a different institution",
                    style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    sameUniversity() ? FlutterIcons.sad_cry_faw5 : Icons.lock,
                    color: Theme.of(context).accentColor,
                    size: 17.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    sameUniversity()
                        ? "Cannot find any posts :("
                        : "You cannot view posts from a different institution",
                    style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget picture() {
    return Container(
      child: user.profileImgUrl != null && user.profileImgUrl.isNotEmpty
          ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 100,
                  child: Image.network(
                    user.profileImgUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: LoadingIndicator(
                                indicatorType: Indicator.circleStrokeSpin,
                                color: Colors.white,
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30.0)),
              child: Icon(AntDesign.user, color: Colors.black)),
    );
  }

  Widget about() {
    return widget.user.about != null && widget.user.about.isNotEmpty
        ? Text(
            widget.user.about,
            style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          )
        : Container();
  }

  callLogout() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final act = CupertinoActionSheet(
        title: Text(
          'Log Out',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        message: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        actions: [
          CupertinoActionSheetAction(
              child: Text(
                "YES",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              onPressed: () async {
                await _firebaseAuth.signOut().then((value) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('uni');
                  prefs.remove('name');
                  prefs.remove('filters');
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()));
                });
              }),
          CupertinoActionSheetAction(
              child: Text(
                "Cancel",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ]);
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  Widget accomplishments() {
    String result = '';
    if (widget.user.accomplishments != null) {
      for (var acc in widget.user.accomplishments) {
        if (acc.isNotEmpty) {
          result = result + '$acc\n\n';
        }
      }
    }
    result.trimRight();
    return result.isNotEmpty
        ? Text(
            result,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).accentColor),
          )
        : SizedBox();
  }

  Widget interests() {
    return user.interests != null && user.interests.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
            child: Wrap(children: _buildChoicesList()),
          )
        // ? Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       // Text(
        //       //   "I'm interested in",
        //       //   style: GoogleFonts.lexendDeca(
        //       //     GoogleFonts.inter: TextStyle(
        //    fontFamily: Constants.fontFamily,
        //       //         fontSize: 15,
        //       //         fontWeight: FontWeight.w500,
        //       //         color: Theme.of(context).accentColor),
        //       //   ),
        //       // ),
        //       // Divider(),
        //       Container(
        //         height: 40.0,
        //         width: MediaQuery.of(context).size.width,
        //         child: Center(
        //           child: ListView(
        //             shrinkWrap: true,
        //             scrollDirection: Axis.horizontal,
        //             children: _buildChoicesList(),
        //           ),
        //         ),
        //       ),
        //       SizedBox(height: 5.0),
        //     ],
        //   )
        : SizedBox();
  }

  Widget socials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (widget.user.snapchatHandle != null &&
                widget.user.snapchatHandle.isNotEmpty) {
              showHandle(text: widget.user.snapchatHandle);
            } else {
              Toast.show('Snapchat not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child:
                  Icon(FlutterIcons.snapchat_ghost_faw, color: Colors.black)),
        ),
        SizedBox(width: 5.0),
        InkWell(
          onTap: () {
            if (widget.user.linkedinHandle != null &&
                widget.user.linkedinHandle.isNotEmpty) {
              showHandle(text: widget.user.linkedinHandle);
            } else {
              Toast.show('LinkedIn not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(FlutterIcons.linkedin_faw, color: Colors.blue)),
        ),
        SizedBox(width: 5.0),
        InkWell(
          onTap: () {
            if (widget.user.instagramHandle != null &&
                widget.user.instagramHandle.isNotEmpty) {
              showHandle(text: widget.user.instagramHandle);
            } else {
              Toast.show('Instagram not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(FlutterIcons.instagram_faw, color: Colors.black)),
        ),
        SizedBox(width: 5.0),
        Visibility(
          visible: widget.isFromChat == null && sameUniversity(),
          child: InkWell(
            onTap: () {
              goToChat();
            },
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(FlutterIcons.message1_ant, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  _buildChoicesList() {
    List<Widget> choices = List();
    for (var interest in user.interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          selectedColor: Colors.pink,
          label: Text(
            interest,
            style: GoogleFonts.quicksand(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          onSelected: (selected) {
            setState(() {});
          },
          selected: true,
        ),
      ));
    }

    return choices;
  }

  Widget places() {
    return widget.user.interests != null && widget.user.interests.isNotEmpty
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Places i've been to",
              style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
            Divider(),
            Wrap(
              children: _buildPlacesList(),
            ),
            Divider(),
          ])
        : SizedBox();
  }

  _buildPlacesList() {
    List<Widget> choices = List();
    for (var interest in widget.user.interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          selectedColor: Colors.deepPurpleAccent,
          avatar: Text('🇸🇩'),
          label: Text(
            'Sudan',
            style: GoogleFonts.quicksand(
                fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          onSelected: (selected) {
            setState(() {});
          },
          selected: true,
        ),
      ));
    }

    return choices;
  }

  goToChat() {
    var chatId = '';
    var myID = p.firebaseAuth.currentUser.uid;
    var peerId = widget.user.id;
    if (myID.hashCode <= peerId.hashCode) {
      chatId = '$myID-$peerId';
    } else {
      chatId = '$peerId-$myID';
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  receiver: widget.user,
                  chatId: chatId,
                )));
  }

  showHandle({String text}) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: Center(
        child: Text(
          text,
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
      ),
    )..show();
  }

  @override
  void initState() {
    super.initState();
    isBlocked = widget.user.isBlocked;
    user = widget.user;
    postsFuture = p.fetchUserPost(widget.user);
    videosFuture = p.VideoApi.fetchUserVideos(user);
  }

  bool sameUniversity() {
    var uni = Constants.checkUniversity() == 0
        ? 'UofT'
        : Constants.checkUniversity() == 1
            ? 'YorkU'
            : 'WesternU';
    return uni == widget.user.university;
  }

  bool get wantKeepAlive => true;
}
