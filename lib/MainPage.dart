import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:unify/Clubs/clubs_page.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Courses/courses_page.dart';
import 'package:unify/Home/PostWidget.dart';
import 'package:unify/MenuWidget.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart' as u;
import 'package:unify/NewsView.dart';
import 'package:unify/NewsWidget.dart';
import 'package:unify/PostPage.dart';
import 'package:unify/Screens/Welcome/welcome_screen.dart';
import 'package:unify/UserPage.dart';
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
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController bioController = TextEditingController();
  var name = "";
  var uni;
  u.PostUser user;
  Future<List<News>> _future;

  @override
  Widget build(BuildContext context) {
    showProfile(u.PostUser me) {
      bool object_avail = user != null;
      Image imag;
      File f;
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: StatefulBuilder(builder: (context, setState) {
            return object_avail
                ? Stack(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          me.profileImgUrl == null
                              ? me.id == firebaseAuth.currentUser.uid
                                  ? imag != null
                                      ? CircleAvatar(child: imag, radius: 50.0)
                                      : CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius: 50.0,
                                          child: InkWell(
                                              onTap: () async {
                                                var res = await u.getImage();
                                                if (res.isNotEmpty) {
                                                  var image = res[0] as Image;
                                                  var file = res[1] as File;
                                                  setState(() {
                                                    imag = image;
                                                    f = file;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                  FlutterIcons.picture_ant,
                                                  color: Colors.white)))
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 50.0,
                                      child: Icon(FlutterIcons.user_ant,
                                          color: Colors.white))
                              : Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      me.profileImgUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                          Color>(
                                                      Colors.grey.shade600),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10.0),
                          Center(
                              child: Text(
                            me.name == null ? "" : me.name,
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          )),
                          SizedBox(height: 5.0),
                          Center(
                              child: me.id == firebaseAuth.currentUser.uid
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: TextField(
                                        controller: bioController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            hintText:
                                                me.bio == null || me.bio.isEmpty
                                                    ? Constants.dummyDescription
                                                    : me.bio,
                                            hintStyle: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700),
                                            )),
                                        maxLines: null,
                                        style: GoogleFonts.quicksand(
                                          textStyle: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      me.bio == null ? "" : me.bio,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )),
                          SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                  child: Icon(FlutterIcons.linkedin_faw,
                                      color: Colors.blue)),
                              InkWell(
                                  child: Icon(FlutterIcons.instagram_faw,
                                      color: Colors.purple)),
                              InkWell(
                                  child: Icon(FlutterIcons.snapchat_ghost_faw,
                                      color: Colors.black)),
                            ],
                          ),
                          SizedBox(height: 30.0),
                          InkWell(
                            onTap: () async {
                              var appear = user.appear ? false : true;
                              var res = await u.changeAppear(appear);
                              if (res) {
                                setState(() {
                                  user.appear = appear;
                                });
                              }
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      user.appear == false
                                          ? FlutterIcons.eye_ant
                                          : FlutterIcons.eye_off_fea,
                                      color: Colors.blue,
                                      size: 20.0),
                                  SizedBox(width: 5.0),
                                  Text(
                                      user.appear
                                          ? "Hide in Students on Unify"
                                          : "Appear in Students on Unify",
                                      style: GoogleFonts.quicksand(
                                          textStyle: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue)))
                                ]),
                          ),
                          Divider(),
                          SizedBox(height: 10.0),
                          Visibility(
                            visible: me.id == firebaseAuth.currentUser.uid,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 15.0),
                              child: InkWell(
                                onTap: () async {
                                  if (imag == null) {
                                    // just update bio
                                    var res = me.bio != bioController.text
                                        ? await u.updateProfile(
                                            null, bioController.text)
                                        : false;
                                    if (res) {
                                      setState(() {});
                                    }
                                  } else {
                                    // image available, upload image
                                    var url = await uploadImageToStorage(f);
                                    var res = await u.updateProfile(
                                        url, bioController.text);
                                    if (res) {
                                      setState(() {});
                                    }
                                  }
                                  await getUserData();
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Center(
                                    child: Text(
                                      "Update Profile",
                                      style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                    ),
                  );
          }),
          btnOkColor: Colors.deepOrange,
          btnOk: null)
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
          IconButton(
            icon: Icon(AntDesign.user, color: Colors.black),
            onPressed: () {
              if (user == null) {
                u.PostUser dummyUser =
                    u.PostUser(bio: "", id: "", name: "", verified: "");
                showProfile(dummyUser);
              } else {
                showProfile(user);
              }
            },
          ),
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
                                        future: u.myCampusUsers(),
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
                                                u.PostUser user = snap.data[i];
                                                Function f = () {
                                                  showProfile(user);
                                                };
                                                return UserWidget(
                                                  user: user,
                                                  show: f,
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
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print(token);
    });
  }

  Future<Null> refresh() async {
    this.setState(() {});
  }

  Future<Null> getUserData() async {
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
}
