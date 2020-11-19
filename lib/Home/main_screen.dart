import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/FilterPage.dart';
import 'package:unify/pages/MainPage.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';
import 'package:unify/pages/buynsell_page.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/pages/clubs_page.dart';
import 'package:unify/pages/courses_page.dart';
import 'package:unify/Home/home_page.dart';
import 'package:unify/Models/post.dart';

class MainScreen extends StatefulWidget {
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
  PostUser user;
  int _pages = 0;
  bool status = true;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getUserData().then((value) => null);
    _pageController = PageController(initialPage: _pages, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            MainPage(),
            CoursesPage(),
            ClubsPage(),
            MyMatchesPage()
          ],
        ),
        bottomNavigationBar: Container(
          height: kBottomNavigationBarHeight + 30,
          child: CurvedNavigationBar(
            key: _bottomNavigationKey,
            //animationCurve: Curves.easeOutCirc,
            backgroundColor: Theme.of(context).backgroundColor,
            color: Colors.deepPurpleAccent,
            items: [
              Icon(
                FlutterIcons.circle_notch_faw5s,
                color: Colors.white,
              ),
              Icon(
                AntDesign.book,
                color: Colors.white,
              ),
              Icon(
                AntDesign.Trophy,
                color: Colors.white,
              ),
              Icon(
                FlutterIcons.chat_bubble_outline_mdi,
                color: Colors.white,
              ),
            ],
            onTap: (index) {
              _pageController.jumpToPage(index);
              // final CurvedNavigationBarState navBarState =
              //     _bottomNavigationKey.currentState;
              // navBarState.setPage(index);
              // _pageController.jumpToPage(index);
            },
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    contentController.dispose();
  }

  void onPageChanged(int page) {
    final CurvedNavigationBarState navBarState =
        _bottomNavigationKey.currentState;
    navBarState.setPage(page);
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
    });
  }

  @override
  bool get wantKeepAlive => true;
}
