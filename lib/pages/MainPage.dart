import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:unify/Components/app_icons.dart';
import 'package:unify/Components/theme.dart';
import 'package:unify/Components/theme_notifier.dart';
import 'package:unify/pages/CameraScreen.dart';
import 'package:unify/pages/MatchPage.dart';
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/NotificationsPage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/pages/UserSearchPage.dart';
import 'package:unify/pages/VideosPage.dart';
import 'package:unify/pages/clubs_page.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/pages/courses_page.dart';
import 'package:unify/pages/FilterPage.dart';
import 'package:unify/widgets/CalendarWidget.dart';
import 'package:unify/widgets/PostWidget.dart';
import 'package:unify/Widgets/MenuWidget.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/Models/notification.dart' as noti;
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
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController bioController = TextEditingController();
  TextEditingController snapchatController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController instagramController = TextEditingController();

  var name = "";
  var uni;
  var promo;
  u.PostUser user;
  Future<List<News>> _newsFuture;
  Future<List<Post>> _postFuture;
  Future<List<u.PostUser>> _userFuture;
  Future<String> _questionFuture;
  int sortBy = 0;
  String imgUrl;

  Stream<Event> notificationStream;

  Gradient gradient = LinearGradient(colors: [Colors.blue, Colors.pinkAccent]);
  Gradient gradient1 =
      LinearGradient(colors: [Colors.purple, Colors.pink, Colors.blue]);

  var _darkTheme = true;

  // AGORA START

  // AGORA END

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //final themeNotifier = Provider.of<ThemeNotifier>(context);
    //_darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text(
                "TheirCircle",
                style: GoogleFonts.pacifico(
                  textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
            // Text(
            //   "Platform for students",
            //   style: GoogleFonts.quicksand(
            //     textStyle: TextStyle(
            //         fontSize: 13,
            //         fontWeight: FontWeight.w500,
            //         color: Theme.of(context).accentColor),
            //   ),
            // )
          ],
        ),
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: <Widget>[
        //     profile(),
        //     IconButton(
        //       icon: Icon(FlutterIcons.filter_outline_mco,
        //           color: Theme.of(context).accentColor),
        //       onPressed: () {
        //         showBarModalBottomSheet(
        //             context: context,
        //             expand: true,
        //             builder: (context) => FilterPage()).then((value) {
        //           if (value == false) {
        //             return;
        //           }
        //           setState(() {
        //             _postFuture = fetchPosts(sortBy);
        //           });
        //         });
        //         // Navigator.push(context,
        //         //         MaterialPageRoute(builder: (context) => FilterPage()))
        //         //     .then((value) {
        //         //   if (value == false) {
        //         //     return;
        //         //   }
        //         //   setState(() {
        //         //     _postFuture = fetchPosts(sortBy);
        //         //   });
        //         // });
        //       },
        //     ),
        //     // Expanded(
        //     //     child: Center(
        //     //         child: Icon(FlutterIcons.circle_notch_faw5s,
        //     //             color: Theme.of(context).accentColor)))
        //   ],
        // ),

        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Column(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         Icon(
        //           FlutterIcons.circle_notch_faw5s,
        //           color: Colors.deepPurpleAccent,
        //         ),
        //         // Text(
        //         //   "Platform for Students",
        //         //   style: GoogleFonts.quicksand(
        //         //     textStyle: TextStyle(
        //         //         fontSize: 12,
        //         //         fontWeight: FontWeight.w500,
        //         //         color: Theme.of(context).accentColor),
        //         //   ),
        //         // ),
        //       ],
        //     ),
        //   ],
        // ),
        // leading: IconButton(
        //   icon: Icon(AntDesign.user, color: Theme.of(context).accentColor),
        //   onPressed: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) =>
        //                 MyProfilePage(user: user, heroTag: user.id)));
        //   },
        // ),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(FlutterIcons.video_library_mdi,
          //       color: Theme.of(context).accentColor),
          //   onPressed: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => VideosPage()));
          //   },
          // ),
          IconButton(
            icon: Unicon(UniconData.uniSearch,
                size: 25.0, color: Theme.of(context).accentColor),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserSearchPage()));
            },
          ),
          notifications(),
          // IconButton(
          //   icon: Icon(FlutterIcons.filter_outline_mco,
          //       color: Theme.of(context).accentColor),
          //   onPressed: () {
          //     Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => FilterPage()))
          //         .then((value) {
          //       if (value == false) {
          //         return;
          //       }
          //       setState(() {
          //         _postFuture = fetchPosts(sortBy);
          //       });
          //     });
          //   },
          // ),

          IconButton(
            icon: Unicon(UniconData.uniCommentMessage,
                size: 25.0, color: Theme.of(context).accentColor),
            onPressed: () {
              widget.goToChat();
            },
          )

          // IconButton(
          //   icon: Icon(AntDesign.logout,
          //       color: Theme.of(context).accentColor, size: 20),
          //   onPressed: () async {
          //     callLogout();
          //   },
          // )
        ],
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(children: [
          ListView(
            children: <Widget>[
              // Container(
              //   height: 100,
              //   child: getStories(),
              // ),
              promoWidget(),
              WelcomeWidget(),
              questionWidget(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: Text(
                  "Recent University News",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              newsListWidget(),
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
                            fontSize: 15,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              postWidget()
            ],
          ),
        ]),
      ),
      floatingActionButton: Container(
        width: 40,
        height: 40,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0.0,
          child: Unicon(UniconData.uniPlus,
              color: Theme.of(context).backgroundColor),
          onPressed: () async {
            showBarModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) => PostPage()).then((refresh) {
              if (refresh == false) {
                return;
              }
              setState(() {
                _postFuture = fetchPosts(sortBy);
              });
            });
          },
        ),
      ),
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
                  style: TextStyle(color: Colors.white)))
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
                            width: 20,
                            height: 20,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballScaleMultiple,
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
  void initState() {
    super.initState();
    notificationStream = FirebaseDatabase.instance
        .reference()
        .child('notifications')
        .child(firebaseAuth.currentUser.uid)
        .onValue;
    getUserData().then((value) {
      _newsFuture = uni == 1
          ? scrapeYorkUNews()
          : uni == 0
              ? scrapeUofTNews()
              : scrapeWesternUNews();
      _postFuture = fetchPosts(sortBy);
      _userFuture = u.myCampusUsers();
      _questionFuture = fetchQuestion();
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
          setState(() {
            _postFuture = fetchPosts(sortBy);
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
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "You must agree to these terms before posting.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "1. Any type of bullying will not be tolerated.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "2. Zero tolerance policy on exposing people's personal information.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "3. Do not clutter people's feed with useless or offensive information.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "4. If your posts are being reported consistently you will be banned.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "5. Posting explicit photos under any circumstances will not be tolerated.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Keep a clean and friendly environment. Violation of these terms will result in a permanent ban on your account.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 10.0),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  "I agree to these terms.",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
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
    var _promo = await getPromoImage();
    print(_promo);
    setState(() {
      //list.add(liveUser);
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
                showBarModalBottomSheet(
                    context: context,
                    expand: true,
                    builder: (context) => NotificationsPage());
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NotificationsPage()));
              },
              child: Unicon(UniconData.uniBell,
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
                      child: Text('',
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
                    ))
                : Container()
          ]);
        } else {
          return InkWell(
            onTap: () {
              showBarModalBottomSheet(
                  context: context,
                  expand: true,
                  builder: (context) => NotificationsPage());
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => NotificationsPage()));
            },
            child: Icon(AppIcons.notification,
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
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProfilePage(
        //               user: _u,
        //               heroTag: user.id + user.id,
        //               isMyProfile: true,
        //             )));
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
                        height: 25,
                        width: 25,
                        child: Center(
                          child: SizedBox(
                              width: 25,
                              height: 25,
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
            padding: const EdgeInsets.all(0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
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
                  )
                  // child: Image.network(
                  //   promo != null ? promo : '',
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 300,
                  //   fit: BoxFit.cover,
                  //   loadingBuilder: (BuildContext context, Widget child,
                  //       ImageChunkEvent loadingProgress) {
                  //     if (loadingProgress == null) return child;
                  //     return SizedBox(
                  //       height: 300,
                  //       width: MediaQuery.of(context).size.width,
                  //       child: Center(
                  //         child: SizedBox(
                  //           width: 20,
                  //           height: 20,
                  //           child: CircularProgressIndicator(
                  //             strokeWidth: 2.0,
                  //             valueColor: new AlwaysStoppedAnimation<Color>(
                  //                 Colors.grey.shade600),
                  //             value: loadingProgress.expectedTotalBytes != null
                  //                 ? loadingProgress.cumulativeBytesLoaded /
                  //                     loadingProgress.expectedTotalBytes
                  //                 : null,
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  ),
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
                setState(() {
                  _postFuture = fetchPosts(sortBy);
                });
              },
            );
          } else {
            return Container();
          }
        });
  }

  Widget newsListWidget() {
    return Visibility(
      visible: uni != null,
      child: Container(
        height: 100,
        child: FutureBuilder(
            future: _newsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return Center(
                    child: SizedBox(
                        width: 40,
                        height: 40,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballScaleMultiple,
                          color: Theme.of(context).accentColor,
                        )));
              else if (snap.hasData)
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snap.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    News news = snap.data[index];
                    return NewsWidget(
                      news: news,
                    );
                  },
                );
              else if (snap.hasError)
                return Container();
              else
                return Container();
            }),
      ),
    );
  }

  Widget postWidget() {
    return FutureBuilder(
        future: _postFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballScaleMultiple,
                      color: Theme.of(context).accentColor,
                    )));
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
                  var res = await u.block(post.userId, post.userId);
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
                var timeAgo =
                    new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
                return PostWidget(
                    key: ValueKey(post.id),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      )),
                ],
              ),
            );
          } else {
            return Text('');
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
