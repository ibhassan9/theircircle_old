import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:unify/Screens/Welcome/welcome_screen.dart';
import 'package:unify/BuyNSell/buynsell_page.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Clubs/clubs_page.dart';
import 'package:unify/Courses/courses_page.dart';
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
  TextEditingController clubNameController = TextEditingController();
  TextEditingController clubDescriptionController = TextEditingController();
  int _pages = 0;
  bool status = true;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pages, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String title() {
      switch (_pages) {
        case 0:
          return "Unify";
        case 1:
          return "Courses";
        case 2:
          return "Clubs";
        case 3:
          return "Chats";
        case 4:
          return "Profile";
        default:
          return "Unify";
      }
    }

    addClubDialog() {
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create a Virtual Club",
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: clubNameController,
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Ex. Football Society"),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                TextField(
                  controller: clubDescriptionController,
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Describe your club here..."),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          }),
          btnOkColor: Colors.deepPurple,
          btnOkOnPress: () async {
            // create club
            var club = Club(
                name: clubNameController.text,
                description: clubDescriptionController.text);
            var result = await createClub(club);

            if (result) {
              setState(() {});
              clubNameController.clear();
              clubDescriptionController.clear();
            } else {
              // result creation error
            }
          })
        ..show();
    }

    showAddDialog() {
      Image imag;
      File f;
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create New Post",
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                imag == null
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.image,
                                  color: Colors.grey.shade600),
                              onPressed: () async {
                                var res = await getImage();
                                if (res.isNotEmpty) {
                                  var image = res[0] as Image;
                                  var file = res[1] as File;
                                  setState(() {
                                    imag = image;
                                    f = file;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          child: Container(
                              height: 150,
                              child: Image(
                                image: imag.image,
                              )),
                        )),
                TextField(
                  controller: contentController,
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Where is the Davis?"),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          }),
          btnOkColor: Colors.deepPurple,
          btnOkOnPress: () async {
            var post = Post(
              content: contentController.text,
              isAnonymous: false,
            );

            var res = imag == null
                ? await createPost(post)
                : await uploadImageToStorage(f);
            // res is a boolean if imag is null - string if image available

            imag != null ? post.imgUrl = res : post.imgUrl = null;

            var result = imag != null ? await createPost(post) : true;
            // check if result is true

            setState(() {});
            contentController.clear();
            updateKeepAlive();
          })
        ..show();
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            title(),
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          actions: <Widget>[
            Visibility(
              visible: _pages == 0 || _pages == 2,
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.deepPurple),
                onPressed: () async {
                  _pages == 0 ? showAddDialog() : addClubDialog();
                },
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.deepPurple,
              ),
              onPressed: () async {},
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.deepPurple),
              onPressed: () async {
                final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
                await _firebaseAuth.signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()));
                });
              },
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            HomePage(),
            CoursesPage(),
            ClubsPage(),
            HomePage()
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _pages,
          iconSize: 30.0,
          selectedColor: Colors.black,
          strokeColor: Colors.white,
          unSelectedColor: Colors.grey[400],
          backgroundColor: Colors.white,
          items: [
            CustomNavigationBarItem(icon: Icons.gesture),
            CustomNavigationBarItem(
              icon: Icons.search,
            ),
            CustomNavigationBarItem(
              icon: Icons.group_work,
            ),
            CustomNavigationBarItem(
              icon: Icons.person_pin,
            ),
          ],
          onTap: (index) {
            setState(() {
              _pages = index;
            });
            _pageController.jumpToPage(index);
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    contentController.dispose();
    clubNameController.dispose();
    clubDescriptionController.dispose();
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

  @override
  bool get wantKeepAlive => true;
}
