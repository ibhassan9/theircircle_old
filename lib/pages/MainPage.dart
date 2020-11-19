import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:unify/Components/theme.dart';
import 'package:unify/Components/theme_notifier.dart';
import 'package:unify/pages/CameraScreen.dart';
import 'package:unify/pages/clubs_page.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/pages/courses_page.dart';
import 'package:unify/pages/FilterPage.dart';
import 'package:unify/widgets/CalendarWidget.dart';
import 'package:unify/widgets/PostWidget.dart';
import 'package:unify/Widgets/MenuWidget.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart' as u;
import 'package:unify/pages/NewsView.dart';
import 'package:unify/Widgets/NewsWidget.dart';
import 'package:unify/pages/PostPage.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';
import 'package:unify/pages/UserPage.dart';
import 'package:unify/Widgets/UserWidget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/pages/WebPage.dart';
import 'package:unify/Widgets/WelcomeWidget.dart';
import 'package:unify/widgets/TodaysQuestionWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController contentController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController bioController = TextEditingController();
  TextEditingController snapchatController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController instagramController = TextEditingController();

  var name = "";
  var uni;
  u.PostUser user;
  Future<List<News>> _newsFuture;
  Future<List<Post>> _postFuture;
  Future<List<u.PostUser>> _userFuture;
  Future<String> _questionFuture;
  int sortBy = 0;

  var _darkTheme = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: false,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                Text(
                  "Platform for Students",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.theme_light_dark_mco,
                color: Theme.of(context).accentColor),
            onPressed: () {
              setState(() {
                _darkTheme = _darkTheme == true ? false : true;
              });
              onThemeChanged(_darkTheme, themeNotifier);
            },
          ),
          IconButton(
            icon: Icon(AntDesign.filter, color: Theme.of(context).accentColor),
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FilterPage()))
                  .then((value) {
                setState(() {
                  _postFuture = fetchPosts(sortBy);
                });
              });
            },
          ),
          IconButton(
            icon: Icon(AntDesign.user, color: Theme.of(context).accentColor),
            onPressed: () {
              if (user == null) {
                u.PostUser dummyUser =
                    u.PostUser(bio: "", id: "", name: "", verified: 1);
                u.showProfile(
                    dummyUser,
                    context,
                    bioController,
                    snapchatController,
                    instagramController,
                    linkedinController,
                    null,
                    null);
              } else {
                Function a = () async {
                  var res = await u.updateProfile(
                      null,
                      bioController.text,
                      snapchatController.text,
                      linkedinController.text,
                      instagramController.text);
                  Navigator.pop(context);
                  if (res) {
                    var id = firebaseAuth.currentUser.uid;
                    await u.getUser(id).then((value) {
                      setState(() {
                        user = value;
                      });
                    });
                  }
                  bioController.clear();
                  snapchatController.clear();
                  linkedinController.clear();
                  instagramController.clear();
                };
                Function b = () async {
                  var id = firebaseAuth.currentUser.uid;
                  await u.getUser(id).then((value) {
                    setState(() {
                      user = value;
                    });
                  });
                };
                u.showProfile(user, context, bioController, snapchatController,
                    instagramController, linkedinController, a, b);
              }
            },
          ),
          // IconButton(
          //   icon: Icon(AntDesign.setting, color:  Theme.of(context).accentColor),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: Icon(AntDesign.logout,
                color: Theme.of(context).accentColor, size: 20),
            onPressed: () async {
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
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomeScreen()));
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
            },
          )
        ],
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(children: [
          ListView(
            children: <Widget>[
              WelcomeWidget(),
              FutureBuilder(
                  future: _questionFuture,
                  builder: (context, snap) {
                    if (snap.hasData && snap.data != null) {
                      return TodaysQuestionWidget(
                        question: snap.data,
                        refresh: () {
                          setState(() {
                            _postFuture = fetchPosts(sortBy);
                          });
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: Text(
                  "Recent University News",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              Visibility(
                visible: uni != null,
                child: Container(
                  height: 100,
                  child: FutureBuilder(
                      future: _newsFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting)
                          return Center(
                              child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme.of(context).accentColor),
                            strokeWidth: 2.0,
                          ));
                        else if (snap.hasData)
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: snap.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              News news = snap.data[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WebPage(
                                            title: news.title,
                                            selectedUrl: news.url)),
                                  );
                                },
                                child: NewsWidget(
                                  news: news,
                                ),
                              );
                            },
                          );
                        else if (snap.hasError)
                          return Container();
                        else
                          return Container();
                      }),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Campus Feed",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (sortBy == 0) {
                            sortBy = 1;
                          } else {
                            sortBy = 0;
                          }
                          _postFuture = fetchPosts(sortBy);
                        });
                      },
                      child: Text(
                        "Sort by: ${sortBy == 0 ? 'Recent' : 'You first'}",
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              FutureBuilder(
                  future: _postFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).accentColor),
                        strokeWidth: 2.0,
                      ));
                    } else if (snap.hasData) {
                      var r = 0;
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snap.data != null ? snap.data.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          Post post = snap.data[index];
                          Function f = () async {
                            var res = await deletePost(post.id, null, null);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                _postFuture = fetchPosts(sortBy);
                              });
                              previewMessage("Post Deleted", context);
                            } else {
                              previewMessage("Error deleting post!", context);
                            }
                          };
                          Function b = () async {
                            var res = await u.block(post.userId);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                _postFuture = fetchPosts(sortBy);
                              });
                              previewMessage("User blocked.", context);
                            }
                          };

                          Function h = () async {
                            var res = await hidePost(post.id);
                            Navigator.pop(context);
                            if (res) {
                              setState(() {
                                _postFuture = fetchPosts(sortBy);
                              });
                              previewMessage("Post hidden from feed.", context);
                            }
                          };
                          var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                              post.timeStamp);
                          if (r == index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Students on TheirCircle",
                                    style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Container(
                                    height: 150,
                                    child: FutureBuilder(
                                        future: _userFuture,
                                        builder: (context, snap) {
                                          if (snap.hasData &&
                                              snap.data.length != 0) {
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              itemCount: snap.data != null
                                                  ? snap.data.length
                                                  : 0,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int i) {
                                                u.PostUser user = snap.data[i];
                                                Function f = () {
                                                  u.showProfile(
                                                      user,
                                                      context,
                                                      bioController,
                                                      snapchatController,
                                                      instagramController,
                                                      linkedinController,
                                                      null,
                                                      null);
                                                };
                                                return UserWidget(
                                                  user: user,
                                                  show: f,
                                                );
                                              },
                                            );
                                          } else {
                                            return Center(
                                              child: Text(
                                                  "No students here yet :(",
                                                  style: GoogleFonts.quicksand(
                                                    textStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  )),
                                            );
                                          }
                                        }),
                                  ),
                                ),
                                Container(
                                  height: 10.0,
                                  width: MediaQuery.of(context).size.width,
                                  color: Theme.of(context).dividerColor,
                                ),
                                PostWidget(
                                    post: post,
                                    timeAgo: timeago.format(timeAgo),
                                    deletePost: f,
                                    block: b,
                                    hide: h),
                              ],
                            );
                          }
                          return PostWidget(
                              post: post,
                              timeAgo: timeago.format(timeAgo),
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
                              Icons.face,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 10),
                            Text("Cannot find any posts :(",
                                style: GoogleFonts.quicksand(
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                )),
                          ],
                        ),
                      );
                    } else {
                      return Text('None');
                    }
                  }),
            ],
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Entypo.pencil, color: Colors.white),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostPage()),
          ).then((value) {
            setState(() {
              _postFuture = fetchPosts(sortBy);
            });
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((value) {
      _newsFuture = uni == 1 ? scrapeYorkUNews() : scrapeUofTNews();
      _postFuture = fetchPosts(sortBy);
      _userFuture = u.myCampusUsers();
      _questionFuture = fetchQuestion();
    });
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
    });
    isFirstLaunch();
  }

  Future<Null> refresh() async {
    getUserData().then((value) {
      _newsFuture = uni == 1 ? scrapeYorkUNews() : scrapeUofTNews();
      _postFuture = fetchPosts(sortBy);
      _userFuture = u.myCampusUsers();
      _questionFuture = fetchQuestion();
    });
    this.setState(() {});
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

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  Future<Null> getUserData() async {
    await Constants.fm.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.getInt('uni');
    var _name = prefs.getString('name');
    var _uni = prefs.getInt('uni');
    var id = firebaseAuth.currentUser.uid;
    var _user = await u.getUser(id);
    setState(() {
      name = _name;
      uni = _uni;
      user = _user;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
