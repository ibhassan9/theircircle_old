import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/CoursenClub.dart';
import 'package:unify/pages/MainPage.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/pages/RoomPage.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/pages/VideosPage.dart';
import 'package:unify/pages/BuyNSellPage.dart';
import 'package:unify/pages/club_page.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/pages/post_detail_page.dart';
import 'package:unify/pages/DB.dart';

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
    updateUserToken();
    if (widget.initialPage != null) {
      setState(() {
        _pages = widget.initialPage;
      });
    }
    getUserData().then((value) => null);
    _pageController = PageController(
        initialPage: widget.initialPage != null ? widget.initialPage : _pages,
        keepPage: true);
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
        handleNotification(message).then((value) {
          navigate(value);
        });
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message != null) {
        handleNotification(message).then((value) {
          navigate(value);
        });
      }
    });

    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(Constants.uniString(uniKey))
        .child(FirebaseAuth.instance.currentUser.uid)
        .child('status')
        .onValue
        .listen((event) {
      if (event.snapshot.value == 1) {
        FirebaseAuth.instance.signOut().then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('uni');
          prefs.remove('name');
          prefs.remove('filters');
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()));
        });
      }
    });

    //TODO:- FINISH NOTIFICATIONS

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     if (message['screen'] == "ROOM_PAGE" ||
    //         message['screen'] == "CHAT_PAGE") {
    //       return;
    //     }
    //     floatNotification(notification: message);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     handleNotification(message).then((value) {
    //       navigate(value);
    //     });
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     handleNotification(message).then((value) {
    //       navigate(value);
    //     });
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {});
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: false,
      backgroundColor: Colors.black,
      body: PageView(
        physics: ClampingScrollPhysics(),
        controller: _mainController,
        children: [
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: onPageChanged,
            children: <Widget>[
              MainPage(goToChat: () {
                _mainController.animateToPage(1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              }),
              CoursenClub(),
              VideosPage(),
              BuyNSell(),
              ProfilePage(
                isMyProfile: true,
                user: user,
                heroTag: user != null ? user.id + user.id + user.id : '',
                isFromMain: true,
              )
            ],
          ),
          MyMatchesPage(backFromChat: () {
            _mainController.animateToPage(0,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          })
        ],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        height: 35,
        iconSize: 26,
        notchSmoothness: NotchSmoothness.softEdge,
        backgroundColor:
            _pages == 2 ? Colors.black : Theme.of(context).backgroundColor,
        splashColor: Colors.deepPurpleAccent,
        splashSpeedInMilliseconds: 500,
        gapLocation: GapLocation.none,
        activeColor: _pages == 0
            ? Colors.deepOrangeAccent
            : _pages == 1
                ? Color(0xffDB5461)
                : _pages == 2
                    ? Colors.pink
                    : _pages == 3
                        ? Colors.teal
                        : Colors.orange,
        inactiveColor: Theme.of(context).buttonColor,
        icons: [
          LineIcons.warehouse,
          LineIcons.award,
          LineIcons.play,
          LineIcons.shoppingBag,
          LineIcons.user
        ],
        activeIndex: _pages,
        onTap: (index) {
          _mainController.animateToPage(0,
              duration: Duration(milliseconds: 10), curve: Curves.elasticIn);
          _pageController.jumpToPage(index);
          setState(() {
            _pages = index;
          });
        },
      ),
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

  // void floatNotification(
  //     {FlashStyle style = FlashStyle.floating,
  //     Map<String, dynamic> notification}) {
  //   showFlash(
  //     context: context,
  //     duration: const Duration(seconds: 4),
  //     persistent: true,
  //     builder: (_, controller) {
  //       return Flash(
  //         margin: const EdgeInsets.all(10.0),
  //         controller: controller,
  //         backgroundColor: Theme.of(context).backgroundColor,
  //         boxShadows: [BoxShadow(blurRadius: 0)],
  //         brightness: Theme.of(context).brightness,
  //         barrierBlur: 3.0,
  //         barrierColor: Colors.transparent,
  //         barrierDismissible: true,
  //         borderRadius: BorderRadius.circular(10.0),
  //         style: style,
  //         position: FlashPosition.top,
  //         onTap: () {
  //           handleNotification(notification).then((value) {
  //             navigate(value);
  //           });
  //         },
  //         child: FlashBar(
  //           title: Text(
  //             notification['aps']['alert']['title'].toString(),
  //             style: GoogleFonts. inter(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //                 color: Theme.of(context).accentColor),
  //           ),
  //           message: Text(
  //             notification['aps']['alert']['body'].toString(),
  //             style: GoogleFonts. inter(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w600,
  //                 color: Theme.of(context).accentColor),
  //           ),
  //           showProgressIndicator: false,
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<Null> getUserData() async {
    var id = FirebaseAuth.instance.currentUser.uid;
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
    var room = data[7];
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
      case 7:
        // go to room chat
        Navigator.push(
            context,
            MaterialPageRoute(
                settings: RouteSettings(name: "/Rooms"),
                builder: (context) => RoomPage(room: room)));
        break;
      default:
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
