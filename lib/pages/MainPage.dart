import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/theme.dart';
import 'package:unify/Components/theme_notifier.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/NotificationsPage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/pages/TodaysQuestionPage.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/widgets/CompleteProfileWidget.dart';
import 'package:unify/widgets/CreateRoomButtonMain.dart';
import 'package:unify/widgets/InviteFriendWidget.dart';
import 'package:unify/widgets/PostWidget.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart' as u;
import 'package:unify/Widgets/NewsWidget.dart';
import 'package:unify/pages/PostPage.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/widgets/RoomWidgetMain.dart';
import 'package:unify/widgets/TodaysQuestionWidget.dart';
import 'package:unify/widgets/WelcomeWidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MainPage extends StatefulWidget {
  final Function goToChat;

  MainPage({Key key, this.goToChat}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController contentController = TextEditingController();

  TextEditingController bioController = TextEditingController();
  TextEditingController snapchatController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController instagramController = TextEditingController();

  var name = "";
  var uni;
  var promo;
  u.PostUser user;
  Future<List<News>> _newsFuture;

  Future<String> _questionFuture;
  Future<List<Room>> _roomFuture;
  int sortBy = 0;
  int sortID = 0;
  String imgUrl;
  bool doneLoading = true;
  String lastPostID = '';
  int lastPostTimeStamp = 0;
  List<Post> posts = [];
  int r = 0;
  bool loadingMore = false;

  StreamController _streamController = StreamController<List<Post>>();

  Stream<Event> notificationStream;

  Gradient gradient = LinearGradient(colors: [Colors.teal, Colors.blue]);
  Gradient gradient1 =
      LinearGradient(colors: [Colors.purple, Colors.pink, Colors.blue]);

  var _darkTheme = true;

  // AGORA START

  // AGORA END

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  // leading: Padding(
                  //   padding: const EdgeInsets.only(left: 10.0),
                  //   child: CircleAvatar(
                  //     radius: 25.0,
                  //     backgroundColor:
                  //         Theme.of(context).accentColor.withOpacity(0.05),
                  //     child: notifications(),
                  //   ),
                  // ),
                  titleSpacing: 10,
                  title: new Text("Your Feed",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  pinned: true,
                  floating: true,
                  snap: true,
                  centerTitle: false,
                  forceElevated: false,
                  elevation: 0.5,
                  actions: [
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 20.0),
                    //   child: InkWell(
                    //       onTap: () {},
                    //       child: Icon(AntDesign.addusergroup,
                    //           size: 25.0,
                    //           color: Theme.of(context).accentColor)),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: notifications(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: InkWell(
                          onTap: () {
                            widget.goToChat();
                          },
                          child: Icon(FlutterIcons.chat_bubble_outline_mdi,
                              size: 25.0,
                              color: Theme.of(context).accentColor)),
                    ),
                  ],
                ),
              ];
            },
            body: Visibility(
              visible: doneLoading == true,
              child: LazyLoadScrollView(
                isLoading: loadingMore,
                onEndOfPage: () async {
                  setState(() {
                    loadingMore = true;
                  });
                  fetchPosts(sortID,
                          lastPostID: lastPostID,
                          lastPostTimeStamp: lastPostTimeStamp)
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
                  onRefresh: refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    children: <Widget>[
                      promoWidget(),
                      WelcomeWidget(),
                      questionWidget(),
                      InkWell(
                          onTap: () async {
                            final RenderBox box = context.findRenderObject();
                            var title = Constants.inviteTitle;
                            await Share.share(title,
                                sharePositionOrigin:
                                    box.localToGlobal(Offset.zero) & box.size);
                          },
                          child: InviteFriendsWidget()),
                      SizedBox(height: 5.0),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Container(
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(20.0),
                            //         border: Border.all(
                            //             width: 1.0,
                            //             color: Theme.of(context)
                            //                 .accentColor
                            //                 .withOpacity(0.5))),
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(6.0),
                            //       child: Icon(LineIcons.campground, size: 15.0),
                            //     )),
                            // SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Rooms',
                                    style: GoogleFonts.quicksand(
                                        height: 0.5,
                                        color: Theme.of(context).accentColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 5.0),
                                Text('Tap in to conversate!',
                                    style: GoogleFonts.quicksand(
                                        height: 1,
                                        color: Theme.of(context).accentColor,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      rooms(),

                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Container(
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(20.0),
                            //         border: Border.all(
                            //             width: 1.0,
                            //             color: Theme.of(context)
                            //                 .accentColor
                            //                 .withOpacity(0.5))),
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(6.0),
                            //       child: Icon(LineIcons.newspaper, size: 15.0),
                            //     )),
                            // SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Articles',
                                    style: GoogleFonts.quicksand(
                                        height: 0.5,
                                        color: Theme.of(context).accentColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 5.0),
                                Text('Stay up-to date with current events',
                                    style: GoogleFonts.quicksand(
                                        height: 1,
                                        color: Theme.of(context).accentColor,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      newsListWidget(),

                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 0.0),
                      //   child: WelcomeWidget(
                      //     create: () {
                      //       showBarModalBottomSheet(
                      //               context: context,
                      //               expand: true,
                      //               builder: (context) => PostPage())
                      //           .then((refresh) {
                      //         if (refresh == false) {
                      //           return;
                      //         }
                      //         fetchPosts(sortBy).then((value) {
                      //           setState(() {
                      //             posts = value;
                      //           });
                      //         });
                      //       });
                      //     },
                      //     answerQuestion: () async {
                      //       var question = await _questionFuture;
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => TodaysQuestionPage(
                      //                   question: question))).then((value) {
                      //         if (value == false) {
                      //           return;
                      //         }
                      //         refresh();
                      //       });
                      //     },
                      //     startRoom: () => print("test"),
                      //   ),
                      // ),

                      // Padding(
                      //   padding:
                      //       const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                      //   child: Text('Latest Articles',
                      //       style: GoogleFonts.quicksand(
                      //           color: Theme.of(context).accentColor,
                      //           fontSize: 17.0,
                      //           fontWeight: FontWeight.bold)),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          height: 8.0,
                        ),
                      ),
                      Container(
                        color: Theme.of(context).backgroundColor,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 7.0, 15.0, 7.0),
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
            ),
          ),
          Visibility(
            visible: doneLoading == false,
            child: Center(
              child: SizedBox(
                  height: 0.0,
                  width: 0.0,
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballScaleMultiple,
                      color: Theme.of(context).accentColor)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrangeAccent,
        mini: false,
        child: Unicon(UniconData.uniPlus, color: Colors.white),
        onPressed: () async {
          // await sendNewQuestionToAll(
          //     title: "We got a question for you!",
          //     body: "What do you like the most about returning to school?");
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

  Widget rooms() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
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
                      itemCount: snap.data.length + 1,
                      itemBuilder: (context, index) {
                        Function reloadRooms = () {
                          setState(() {
                            _roomFuture = Room.fetchAll();
                          });
                        };
                        if (index == 0) {
                          return AnimatedSwitcher(
                            duration: Duration(seconds: 1),
                            child:
                                CreateRoomButtonMain(reloadRooms: reloadRooms),
                          );
                        } else {
                          Room room = snap.data[index - 1];
                          return AnimatedSwitcher(
                            duration: Duration(seconds: 1),
                            child:
                                RoomWidgetMain(room: room, reload: reloadRooms),
                          );
                        }
                      }),
                );
              } else {
                return AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: SizedBox(
                        height: 40,
                        width: 40,
                        child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotateMultiple,
                            color: Colors.deepPurpleAccent)));
              }
            },
          )),
    );
  }

  Widget userProfile() {
    return InkWell(
      onTap: () async {
        print('text');
        print(this.user.university);
        var user =
            await u.getUserWithUniversity(this.user.id, this.user.university);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(
                      user: user,
                      heroTag: this.user.id,
                      isMyProfile: true,
                    )));
      },
      child: user.profileImgUrl == null || user.profileImgUrl == ''
          ? CircleAvatar(
              radius: 5.0,
              backgroundColor: Colors.deepPurpleAccent,
              child: Text(this.user.name.substring(0, 1),
                  style: GoogleFonts.quicksand(color: Colors.white)))
          : Hero(
              tag: UniqueKey().toString(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  this.user.profileImgUrl,
                  width: 10,
                  height: 10,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: SizedBox(
                            width: 15,
                            height: 15,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballClipRotateMultiple,
                              color: Theme.of(context).accentColor,
                            )),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    contentController.dispose();
    bioController.dispose();
    snapchatController.dispose();
    linkedinController.dispose();
    instagramController.dispose();
    _streamController.close();
  }

  @override
  void initState() {
    super.initState();
    notificationStream = FirebaseDatabase.instance
        .reference()
        .child('notifications')
        .child(FIR_UID)
        .onValue;
    getUserData().then((value) {
      _newsFuture = uni == 1
          ? scrapeYorkUNews()
          : uni == 0
              ? scrapeUofTNews()
              : scrapeWesternUNews();
      fetchPosts(sortBy).then((value) {
        setState(() {
          posts = value;
          rand();
        });
      });
      _questionFuture = fetchQuestion();
      _roomFuture = Room.fetchAll();
      isFirstLaunch();
    });
  }

  Future<Null> refresh() async {
    getUserData().then((value) {
      _newsFuture = uni == 1
          ? scrapeYorkUNews()
          : uni == 0
              ? scrapeUofTNews()
              : scrapeWesternUNews();
      fetchPosts(sortBy).then((value) {
        setState(() {
          posts = value;
          rand();
        });
      });
      _questionFuture = fetchQuestion();
      _roomFuture = Room.fetchAll();
    });
    this.setState(() {});
  }

  Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var yes = prefs.getBool('isFirst');
    if (yes == null) {
      terms();
      return true;
    } else {
      List<Post> p = await fetchUserPost(user);
      if (p.isEmpty) {
        showBarModalBottomSheet(
            context: context,
            expand: true,
            builder: (context) => PostPage(intro: true)).then((refresh) {
          if (refresh == false) {
            return;
          }
          fetchPosts(sortBy).then((value) {
            setState(() {
              posts = value;
            });
          });
        });
      }
      return false;
    }
  }

  void terms() async {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "Welcome to TheirCircle",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "You must agree to these terms before posting.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "1. Any type of bullying will not be tolerated.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "2. Zero tolerance policy on exposing people's personal information.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "3. Do not clutter people's feed with useless or offensive information.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "4. If your posts are being reported consistently you will be banned.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "5. Posting explicit photos under any circumstances will not be tolerated.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              Text(
                "Keep a clean and friendly environment. Violation of these terms will result in a permanent ban on your account.",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              SizedBox(height: 10.0),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  "I agree to these terms.",
                  style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isFirst', true);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10.0),
            ],
          ),
        );
      }),
    )..show().then((value) async {});
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  Future<Null> getUserData() async {
    await Constants.fm.requestPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _name = prefs.getString('name');
    var _uni = prefs.getInt('uni');
    var id = FIR_UID;
    var _user = await u.getUser(id);
    var _promo = await getPromoImage();
    print(_promo);
    setState(() {
      name = _name;
      uni = _uni;
      user = _user;
      promo = _promo;
      imgUrl = user.profileImgUrl;
    });
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

  Widget notifications() {
    return StreamBuilder(
      stream: notificationStream,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;
          int notiCount = 0;
          for (var d in data.values) {
            if (d['seen'] != null && d['seen'] == false) {
              notiCount += 1;
            }
          }
          return Stack(alignment: Alignment.center, children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage()));
                // showBarModalBottomSheet(
                //     context: context,
                //     expand: true,
                //     builder: (context) => NotificationsPage());
              },
              child: Icon(FlutterIcons.notifications_none_mdi,
                  size: 25, color: Theme.of(context).accentColor),
            ),
            notiCount > 0
                ? Positioned(
                    top: 15.0,
                    right: 0.0,
                    width: 10.0,
                    height: 10.0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '',
                        style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ))
                : Container()
          ]);
        } else {
          return InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()));
              // showBarModalBottomSheet(
              //     context: context,
              //     expand: true,
              //     builder: (context) => NotificationsPage());
            },
            child: Icon(FlutterIcons.notifications_none_mdi,
                size: 25, color: Theme.of(context).accentColor),
          );
        }
      },
    );
  }

  Widget profile() {
    return InkWell(
      onTap: () async {
        u.PostUser _u = await u.getUserWithUniversity(user.id, user.university);
        showBarModalBottomSheet(
            context: context,
            expand: true,
            builder: (context) => ProfilePage(
                  user: _u,
                  heroTag: UniqueKey().toString(),
                  isMyProfile: true,
                ));
      },
      child: imgUrl == null || imgUrl == ''
          ? Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15.0)))
          : Hero(
              tag: user.id + user.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  color: Colors.grey,
                  child: Image.network(
                    imgUrl,
                    width: 25,
                    height: 25,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 15,
                        width: 15,
                        child: Center(
                          child: SizedBox(
                              width: 15,
                              height: 15,
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballScaleRipple,
                                color: Colors.white,
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  Widget promoWidget() {
    return promo != null && promo.isNotEmpty
        ? Padding(
            key: ValueKey(promo),
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: promo != null ? promo : '',
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    fit: BoxFit.cover,
                  )),
            ),
          )
        : Container();
  }

  Widget questionWidget() {
    return FutureBuilder(
        future: _questionFuture,
        builder: (context, snap) {
          if (snap.hasData && snap.data != null) {
            return TodaysQuestionWidget(
              question: snap.data,
              refresh: () {
                fetchPosts(sortBy).then((value) {
                  setState(() {
                    posts = value;
                  });
                });
              },
            );
          } else {
            return TodaysQuestionWidget(
              question: 'Loading Daily Question...',
              refresh: () {
                fetchPosts(sortBy).then((value) {
                  setState(() {
                    posts = value;
                  });
                });
              },
            );
          }
        });
  }

  Widget newsListWidget() {
    return Visibility(
      visible: uni != null,
      child: Container(
        height: 250,
        child: FutureBuilder(
            future: _newsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: Center(
                      child: SizedBox(
                          width: 0,
                          height: 0,
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotateMultiple,
                            color: Theme.of(context).accentColor,
                          ))),
                );
              else if (snap.hasData)
                return AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: snap.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      News news = snap.data[index];
                      return AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: index == 0 ? 7.0 : 3.0),
                          child: NewsWidget(
                            news: news,
                          ),
                        ),
                      );
                    },
                  ),
                );
              else if (snap.hasError)
                return AnimatedSwitcher(
                    duration: Duration(seconds: 1), child: Container());
              else
                return AnimatedSwitcher(
                    duration: Duration(seconds: 1), child: Container());
            }),
      ),
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
                      var res = await u.block(post.userId, post.userId);
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
                    if (index == r) {
                      return user != null
                          ? user.about == null ||
                                  user.about.isEmpty ||
                                  user.instagramHandle == null ||
                                  user.instagramHandle.isEmpty ||
                                  user.snapchatHandle == null ||
                                  user.snapchatHandle.isEmpty ||
                                  user.profileImgUrl == null ||
                                  user.profileImgUrl.isEmpty
                              ? CompleteProfileWidget()
                              : Container()
                          : Container();
                    } else {
                      return PostWidget(
                          key: ValueKey(post.id),
                          post: post,
                          timeAgo: timeago.format(timeAgo, locale: 'en_short'),
                          deletePost: f,
                          block: b,
                          hide: h);
                    }
                  },
                ),
        ));
  }

  rand() {
    Random rnd;
    int min = 0;
    int max = posts.length;
    rnd = new Random();
    r = min + rnd.nextInt(max - min);
  }

  @override
  bool get wantKeepAlive => true;
}
