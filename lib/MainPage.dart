import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:unify/Clubs/clubs_page.dart';
import 'package:unify/Courses/courses_page.dart';
import 'package:unify/Home/PostWidget.dart';
import 'package:unify/MenuWidget.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/NewsView.dart';
import 'package:unify/NewsWidget.dart';
import 'package:unify/PostPage.dart';
import 'package:unify/Screens/Welcome/welcome_screen.dart';
import 'package:unify/UserWidget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/WebPage.dart';
import 'package:unify/WelcomeWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController contentController = TextEditingController();
  var name = "";
  var uni;
  Future<List<News>> _future;

  @override
  Widget build(BuildContext context) {
    showProfile() {
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
                    "Update Name",
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
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: name.isEmpty ? "" : name),
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
          btnOkColor: Colors.deepOrange,
          btnOkOnPress: () async {
            // update profile information
          })
        ..show();
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
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
                        color: Colors.black),
                  ),
                ),
                Text(
                  "Platform for Students",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(AntDesign.book, color: Colors.black, size: 20),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => CoursesPage()),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: Icon(AntDesign.Trophy, color: Colors.black, size: 20),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => ClubsPage()),
          //     );
          //   },
          // ),

          IconButton(
            icon: Icon(AntDesign.setting, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(AntDesign.logout, color: Colors.black, size: 20),
            onPressed: () async {
              final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
              await _firebaseAuth.signOut().then((value) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('uni');
                prefs.remove('name');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()));
              });
            },
          )
        ],
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(children: [
          ListView(
            children: <Widget>[
              WelcomeWidget(),
              MenuWidget(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: Text(
                  "Recent University News",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              Visibility(
                visible: uni != null,
                child: Container(
                  height: 100,
                  child: FutureBuilder(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting)
                          return Center(
                              child: CircularProgressIndicator(
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
                          return Text("ERROR: ${snap.error}");
                        else
                          return Text('None');
                      }),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "Campus Feed",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              FutureBuilder(
                  future: fetchPosts(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
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
                              setState(() {});
                              previewMessage("Post Deleted", context);
                            } else {
                              previewMessage("Error deleting post!", context);
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
                                    "Students on Unify",
                                    style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Container(
                                    height: 150,
                                    child: FutureBuilder(
                                        future: myCampusUsers(),
                                        builder: (context, snap) {
                                          if (snap.hasData) {
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
                                                PostUser user = snap.data[i];
                                                return UserWidget(
                                                  user: user,
                                                );
                                              },
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }),
                                  ),
                                ),
                                Container(
                                  height: 10.0,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey.shade50,
                                ),
                                PostWidget(
                                    post: post,
                                    timeAgo: timeago.format(timeAgo),
                                    deletePost: f)
                              ],
                            );
                          }
                          return PostWidget(
                              post: post,
                              timeAgo: timeago.format(timeAgo),
                              deletePost: f);
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
        backgroundColor: Colors.deepOrange,
        child: Icon(Entypo.pencil, color: Colors.white),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostPage()),
          ).then((value) {
            setState(() {});
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    _future = uni == 1 ? scrapeYorkUNews() : scrapeUofTNews();
  }

  Future<Null> refresh() async {
    this.setState(() {});
  }

  Future<Null> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.getInt('uni');
    var _name = prefs.getString('name');
    var _uni = prefs.getInt('uni');
    setState(() {
      name = _name;
      uni = _uni;
    });
  }
}
