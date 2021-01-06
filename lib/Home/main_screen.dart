import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Components/app_icons.dart';
import 'package:unify/Components/theme.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/FilterPage.dart';
import 'package:unify/pages/MainPage.dart';
import 'package:unify/pages/MatchPage.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';
import 'package:unify/pages/TodaysQuestionPage.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/pages/VideosPage.dart';
import 'package:unify/pages/buynsell_page.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/pages/club_page.dart';
import 'package:unify/pages/clubs_page.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/pages/courses_page.dart';
import 'package:unify/Home/home_page.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/post_detail_page.dart';

class MainScreen extends StatefulWidget {
  final int initialPage;

  MainScreen({Key key, this.initialPage}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  PageController _pageController;
  TextEditingController contentController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController bioController = TextEditingController();
  TextEditingController snapchatController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController clubNameController = TextEditingController();
  TextEditingController clubDescriptionController = TextEditingController();
  PageController _mainController = PageController();
  PostUser user;
  int _pages = 0;
  bool status = true;
  GlobalKey _bottomNavigationKey = GlobalKey();
  String imgUrl;

  @override
  void initState() {
    super.initState();
    if (widget.initialPage != null) {
      setState(() {
        _pages = widget.initialPage;
      });
    }
    getUserData().then((value) => null);
    _pageController = PageController(
        initialPage: widget.initialPage != null ? widget.initialPage : _pages,
        keepPage: true);
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {
        handleNotification(message).then((value) {
          navigate(value);
        });
      },
      onResume: (Map<String, dynamic> message) async {
        handleNotification(message).then((value) {
          navigate(value);
        });
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageView(
      physics: ClampingScrollPhysics(),
      controller: _mainController,
      children: [
        Scaffold(
          extendBody: false,
          body: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: onPageChanged,
            children: <Widget>[
              MainPage(goToChat: () {
                _mainController.animateToPage(1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              }),
              CoursesPage(),
              VideosPage(),
              ClubsPage(),
              //MyMatchesPage()
              ProfilePage(
                isMyProfile: true,
                user: user,
                heroTag: user != null ? user.id + user.id + user.id : '',
                isFromMain: true,
              )
            ],
          ),
          bottomNavigationBar: Container(
            height: kBottomNavigationBarHeight + 23,
            decoration: BoxDecoration(
                color: _pages == 2
                    ? Colors.black.withOpacity(0.99)
                    : Theme.of(context).backgroundColor,
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).accentColor.withOpacity(0.1),
                        width: 1.0))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(0);
                      setState(() {
                        _pages = 0;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(FlutterIcons.circle_notch_faw5s,
                            color: _pages == 2
                                ? Colors.white
                                : Theme.of(context).accentColor,
                            size: 23.0),
                        // SizedBox(height: 3.0),
                        // Text(
                        //   'Home',
                        //   style: GoogleFonts.quicksand(
                        //     textStyle: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w400,
                        //         color: _pages == 2
                        //             ? Colors.grey
                        //             : _pages == 0
                        //                 ? Theme.of(context).accentColor
                        //                 : Colors.grey),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(1);
                      setState(() {
                        _pages = 1;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                            _pages == 1
                                ? FlutterIcons.book_mco
                                : FlutterIcons.book_outline_mco,
                            color: _pages == 2
                                ? Colors.white
                                : Theme.of(context).accentColor,
                            size: 23.0),

                        // SizedBox(height: 3.0),
                        // Text(
                        //   'Courses',
                        //   style: GoogleFonts.quicksand(
                        //     textStyle: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w400,
                        //         color: _pages == 2
                        //             ? Colors.grey
                        //             : _pages == 1
                        //                 ? Theme.of(context).accentColor
                        //                 : Colors.grey),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(2);
                      setState(() {
                        _pages = 2;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                            _pages == 2
                                ? AppIcons.play_button__1_
                                : AppIcons.play_button,
                            color: _pages == 2
                                ? Colors.white
                                : Theme.of(context).accentColor,
                            size: 23.0),
                        // SizedBox(height: 3.0),
                        // Text(
                        //   'UniTV',
                        //   style: GoogleFonts.quicksand(
                        //     textStyle: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w400,
                        //         color: _pages == 2 ? Colors.white : Colors.grey),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(3);
                      setState(() {
                        _pages = 3;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                            _pages == 3
                                ? FlutterIcons.account_group_mco
                                : FlutterIcons.account_group_outline_mco,
                            color: _pages == 2
                                ? Colors.white
                                : Theme.of(context).accentColor,
                            size: 23.0),
                        // SizedBox(height: 3.0),
                        // Text(
                        //   'Clubs',
                        //   style: GoogleFonts.quicksand(
                        //     textStyle: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w400,
                        //         color: _pages == 2
                        //             ? Colors.grey
                        //             : _pages == 3
                        //                 ? Theme.of(context).accentColor
                        //                 : Colors.grey),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      var id = firebaseAuth.currentUser.uid;
                      var _user = await getUser(id);
                      setState(() {
                        user = _user;
                      });
                      _pageController.jumpToPage(4);
                      setState(() {
                        _pages = 4;
                      });
                    },
                    child: Column(
                      children: [
                        profile()

                        // SizedBox(height: 3.0),
                        // Text(
                        //   'Chat',
                        //   style: GoogleFonts.quicksand(
                        //     textStyle: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w400,
                        //         color: _pages == 2
                        //             ? Colors.grey
                        //             : _pages == 4
                        //                 ? Theme.of(context).accentColor
                        //                 : Colors.grey),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  // BottomNavigationBarItem(
                  //           icon: Icon(FlutterIcons.circle_notch_faw5s),
                  //           title: Text('Home')),
                  //       CustomNavigationBarItem(
                  //           icon: Icon(AntDesign.book), title: Text('Courses')),
                  //       CustomNavigationBarItem(
                  //           icon: Icon(FlutterIcons.video_camera_faw),
                  //           title: Text('UniTV')),
                  //       CustomNavigationBarItem(
                  //           icon: Icon(AntDesign.Trophy), title: Text('Clubs')),
                  //       CustomNavigationBarItem(
                  //           icon: Icon(FlutterIcons.chat_bubble_outline_mdi),
                  //           title: Text('Chat')),
                ],
              ),
            ),
          ),
          // bottomNavigationBar: Container(
          //   color: Colors.red,
          //   height: kBottomNavigationBarHeight + 40,
          //   child: Stack(
          //     children: [
          //       Positioned(
          //         top: 0.0,
          //         child: CustomNavigationBar(
          //           //index: widget.initialPage != null ? widget.initialPage : 0,
          //           key: _bottomNavigationKey,
          //           currentIndex: _pages,
          //           elevation: 1.5,
          //           //animationCurve: Curves.easeOutCirc,
          //           backgroundColor: widget.initialPage == null
          //               ? _pages == 2
          //                   ? Colors.black
          //                   : Theme.of(context).backgroundColor
          //               : widget.initialPage == 2
          //                   ? _pages == 2
          //                       ? Colors.black
          //                       : Theme.of(context).backgroundColor
          //                   : Theme.of(context).backgroundColor,
          //           // color: widget.initialPage == null
          //           //     ? _pages == 2
          //           //         ? Colors.black
          //           //         : Colors.deepPurpleAccent
          //           //     : widget.initialPage == 2
          //           //         ? _pages == 2
          //           //             ? Colors.black
          //           //             : Colors.deepPurpleAccent
          //           //         : Colors.deepPurpleAccent,
          //           items: [
          //             CustomNavigationBarItem(
          //                 icon: Icon(FlutterIcons.circle_notch_faw5s),
          //                 title: Text('Home')),
          //             CustomNavigationBarItem(
          //                 icon: Icon(AntDesign.book), title: Text('Courses')),
          //             CustomNavigationBarItem(
          //                 icon: Icon(FlutterIcons.video_camera_faw),
          //                 title: Text('UniTV')),
          //             CustomNavigationBarItem(
          //                 icon: Icon(AntDesign.Trophy), title: Text('Clubs')),
          //             CustomNavigationBarItem(
          //                 icon: Icon(FlutterIcons.chat_bubble_outline_mdi),
          //                 title: Text('Chat')),
          //             // Icon(
          //             //   FlutterIcons.circle_notch_faw5s,
          //             //   color: Colors.white,
          //             // ),
          //             // Icon(
          //             //   AntDesign.book,
          //             //   color: Colors.white,
          //             // ),
          //             // Icon(FlutterIcons.video_camera_faw, color: Colors.white),
          //             // Icon(
          //             //   AntDesign.Trophy,
          //             //   color: Colors.white,
          //             // ),
          //             // Icon(
          //             //   FlutterIcons.chat_bubble_outline_mdi,
          //             //   color: Colors.white,
          //             // ),
          //           ],
          //           onTap: (index) {
          //             _pageController.jumpToPage(index);
          //             // setState(() {
          //             //   _pages = index;
          //             // });
          //             // final CurvedNavigationBarState navBarState =
          //             //     _bottomNavigationKey.currentState;
          //             // navBarState.setPage(index);
          //             // _pageController.jumpToPage(index);
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ),
        MyMatchesPage(backFromChat: () {
          _mainController.animateToPage(0,
              duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        })
      ],
    );
  }

  Widget profile() {
    return imgUrl == null || imgUrl == ''
        ? Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
                border: _pages == 4
                    ? Border.all(color: Colors.black)
                    : _pages == 2
                        ? Border.all(color: Colors.white)
                        : null,
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15.0)))
        : Hero(
            tag: user.id + user.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: _pages == 4
                      ? Border.all(color: Colors.black)
                      : _pages == 2
                          ? Border.all(color: Colors.white)
                          : null,
                ),
                child: Image.network(
                  imgUrl,
                  width: 23,
                  height: 23,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 23,
                      width: 23,
                      child: Center(
                        child: SizedBox(
                            width: 23,
                            height: 23,
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
          );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _mainController.dispose();
    contentController.dispose();
  }

  void onPageChanged(int page) {
    // final CurvedNavigationBarState navBarState =
    //     _bottomNavigationKey.currentState;
    // navBarState.setPage(page);
    setState(() {
      this._pages = page;
    });
  }

  void navigationTapped(int page) {
    final CurvedNavigationBarState navBarState =
        _bottomNavigationKey.currentState;
    navBarState.setPage(page);
    _pageController.jumpToPage(page);
  }

  Future<Null> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.getInt('uni');
    var _name = prefs.getString('name');
    var _uni = prefs.getInt('uni');
    var id = firebaseAuth.currentUser.uid;
    var _user = await getUser(id);
    setState(() {
      user = _user;
      imgUrl = user.profileImgUrl;
    });
    print(user.name);
  }

  navigate(List<dynamic> data) {
    var type = data[0];
    var post = data[1];
    var course = data[2];
    var club = data[3];
    var video = data[4];
    var receiver = data[5];
    var chatId = data[6];
    switch (type) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostDetailPage(post: post, course: course, timeAgo: '')));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CoursePage(course: course)));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PostDetailPage(post: post, club: club, timeAgo: '')));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ClubPage(club: club)));
        break;
      case 4:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostDetailPage(
                      post: post,
                      timeAgo: '',
                    )));
        break;
      case 5:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatPage(receiver: receiver, chatId: chatId)));
        break;
      case 6:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPreview(video: video, timeAgo: '')));
        break;
      default:
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
