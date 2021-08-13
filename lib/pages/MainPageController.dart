import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/ExplorePage.dart';
import 'package:unify/pages/FeedPage.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/NotificationsPage.dart';

class MainPageController extends StatefulWidget {
  final Function goToProfile;
  MainPageController({this.goToProfile});
  @override
  _MainPageControllerState createState() => _MainPageControllerState();
}

class _MainPageControllerState extends State<MainPageController>
    with AutomaticKeepAliveClientMixin {
  PostUser user;
  int selectedPage = 0;
  Stream<Event> notificationStream;
  PageController pageController;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: body(),
    );
  }

  Widget body() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        this.setState(() {
          selectedPage = index;
        });
      },
      children: [FeedPage(), Explore(), MyMatchesPage()],
    );
  }

  AppBar appBar() {
    return new AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      leading: userProfile(),
      leadingWidth: 40.0,
      title: selectionBar(),
      centerTitle: true,
      elevation: 0.5,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: notifications(),
        ),
      ],
    );
  }

  Widget userProfile() {
    return InkWell(
      onTap: () async {
        widget.goToProfile();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: user == null
            ? Container()
            : user.profileImgUrl == null || user.profileImgUrl == ''
                ? CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Text(this.user.name.substring(0, 1),
                        style: GoogleFonts.quicksand(color: Colors.white)))
                : CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage(user.profileImgUrl),
                    backgroundColor: Colors.transparent,
                  ),
      ),
    );
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
              },
              child: Icon(Icons.notifications_active,
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
            },
            child: Icon(Icons.notifications_on_outlined,
                size: 25, color: Theme.of(context).accentColor),
          );
        }
      },
    );
  }

  Widget selectionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              selectedPage = 0;
            });
            pageController.animateToPage(selectedPage,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          },
          child: Column(
            children: [
              Text(
                'Feed',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedPage == 0
                        ? Theme.of(context).accentColor
                        : Theme.of(context).buttonColor),
              ),
              SizedBox(height: 3.0),
              CircleAvatar(
                radius: 3.0,
                backgroundColor: selectedPage == 0
                    ? Colors.deepPurpleAccent
                    : Colors.transparent,
              )
            ],
          ),
        ),
        SizedBox(width: 10.0),
        InkWell(
          onTap: () {
            setState(() {
              selectedPage = 1;
            });
            pageController.animateToPage(selectedPage,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          },
          child: Column(
            children: [
              Text(
                'Digest',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedPage == 1
                        ? Theme.of(context).accentColor
                        : Theme.of(context).buttonColor),
              ),
              SizedBox(height: 3.0),
              CircleAvatar(
                radius: 3.0,
                backgroundColor: selectedPage == 1
                    ? Colors.deepPurpleAccent
                    : Colors.transparent,
              )
            ],
          ),
        ),
        SizedBox(width: 10.0),
        InkWell(
          onTap: () {
            setState(() {
              selectedPage = 2;
            });
            pageController.animateToPage(selectedPage,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          },
          child: Column(
            children: [
              Text(
                'Messages',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedPage == 2
                        ? Theme.of(context).accentColor
                        : Theme.of(context).buttonColor),
              ),
              SizedBox(height: 3.0),
              CircleAvatar(
                radius: 3.0,
                backgroundColor: selectedPage == 2
                    ? Colors.deepPurpleAccent
                    : Colors.transparent,
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(keepPage: true);
    getInitialData();
  }

  getInitialData() async {
    notificationStream = FirebaseDatabase.instance
        .reference()
        .child('notifications')
        .child(FIR_UID)
        .onValue;
    var id = FIR_UID;
    var _user = await getUser(id);
    setState(() {
      user = _user;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
