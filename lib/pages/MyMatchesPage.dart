import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/UserSearchPage.dart';
import 'package:unify/widgets/MyConversationWidget.dart';
import 'package:unify/widgets/MyMatchWidget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

class MyMatchesPage extends StatefulWidget {
  final Function backFromChat;

  MyMatchesPage({Key key, this.backFromChat}) : super(key: key);
  @override
  _MyMatchesPageState createState() => _MyMatchesPageState();
}

class _MyMatchesPageState extends State<MyMatchesPage>
    with AutomaticKeepAliveClientMixin {
  var db = FirebaseDatabase.instance.reference().child('users');
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Stream<Event> myStream;

  Map<String, String> blockList = {};
  bool hasInitialized = false;

  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: ValueKey('chat_page_detector'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 1.0) {
          if (hasInitialized) {
            getBlocks().then((value) {
              setState(() {
                blockList = value;
              });
            });
          }
        } else if (info.visibleFraction == 0.0) {}
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: UserSearchPage()));
                    // Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => UserSearchPage()))
                    //     .then((value) {});
                  },
                  child: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).buttonColor.withOpacity(0.05),
                      radius: 17.5,
                      child: Icon(FlutterIcons.search1_ant,
                          size: 20.0, color: Theme.of(context).accentColor))),
            ),
          ],
          brightness: Theme.of(context).brightness,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.5,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: InkWell(
                onTap: () {
                  widget.backFromChat();
                },
                child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).buttonColor.withOpacity(0.05),
                    radius: 25.0,
                    child: Icon(Feather.home,
                        size: 20.0, color: Theme.of(context).accentColor))),
          ),
          leadingWidth: 50.0,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          title: Text(
            "Chat",
            style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).accentColor),
          ),
        ),
        body: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0)),
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).backgroundColor,
            child: Stack(
              children: [
                ListView(children: [
                  SizedBox(height: 10.0),
                  StreamBuilder(
                    stream: myStream,
                    builder: (context, snap) {
                      List<Match> chats = [];
                      if (snap.hasData &&
                          !snap.hasError &&
                          snap.data.snapshot.value != null) {
                        Map values = snap.data.snapshot.value;
                        for (var key in values.keys) {
                          if (!blockList.containsKey(key)) {
                            var peerId = key;
                            var lastMessage = values[key]['lastMessage'];
                            var lastMessageSenderId = values[key]['senderId'];
                            var timestamp = values[key]['timestamp'];
                            var seen = values[key]['seen'] != null
                                ? values[key]['seen']
                                : false;
                            var chatId = '';
                            var myID = firebaseAuth.currentUser.uid;
                            if (myID.hashCode <= peerId.hashCode) {
                              chatId = '$myID-$peerId';
                            } else {
                              chatId = '$peerId-$myID';
                            }
                            var match = Match(
                                peerId: peerId,
                                chatId: chatId,
                                lastMessage: lastMessage,
                                timestamp: timestamp,
                                seen: seen,
                                lastMessageSenderId: lastMessageSenderId);
                            chats.add(match);
                          }
                        }
                      } else if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: SizedBox(
                                height: 15,
                                width: 15,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.circleStrokeSpin,
                                    color: Theme.of(context).accentColor)));
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height / 1.4,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FlutterIcons.chat_ent,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Your chat list is empty",
                                  style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                      return FutureBuilder(
                        future: users(chats),
                        builder: (_, s) {
                          if (snap.hasData && snap.data != null) {
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: chats != null ? chats.length : 0,
                              itemBuilder: (BuildContext context, int index) {
                                Match chat = chats[index];
                                var timeAgo =
                                    new DateTime.fromMillisecondsSinceEpoch(
                                        chat.timestamp);
                                var time =
                                    timeago.format(timeAgo, locale: 'en');
                                Function reload = () {
                                  setState(() {
                                    myStream = db.onValue;
                                  });
                                };

                                if (s.hasData &&
                                    s.data.length == chats.length) {
                                  PostUser u = s.data[index];
                                  return Column(
                                    children: [
                                      MyConversationWidget(
                                          key: ValueKey(u.id),
                                          peerId: chat.peerId,
                                          lastMessage: chat.lastMessage,
                                          chatId: chat.chatId,
                                          timestamp: chat.timestamp,
                                          reload: reload,
                                          peer: u,
                                          timeAgo: time,
                                          seen: chat.seen,
                                          lastMessageSenderId:
                                              chat.lastMessageSenderId),
                                      // Divider(
                                      //     color: Theme.of(context).dividerColor,
                                      //     thickness: 0.5)
                                      // Padding(
                                      //   padding: const EdgeInsets.all(8.0),
                                      //   child: Divider(),
                                      // ),
                                    ],
                                  );
                                } else if (s.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                  // return Row(
                                  //   children: [
                                  //     Shimmer.fromColors(
                                  //         baseColor:
                                  //             Theme.of(context).dividerColor,
                                  //         highlightColor:
                                  //             Theme.of(context).buttonColor,
                                  //         child: CircleAvatar(radius: 15.0)),
                                  //     Column(children: [
                                  //       Shimmer.fromColors(
                                  //           baseColor:
                                  //               Theme.of(context).dividerColor,
                                  //           highlightColor:
                                  //               Theme.of(context).buttonColor,
                                  //           child: SizedBox(
                                  //               height: 20,
                                  //               width: MediaQuery.of(context)
                                  //                       .size
                                  //                       .width /
                                  //                   2)),
                                  //       SizedBox(height: 5.0),
                                  //       Shimmer.fromColors(
                                  //           baseColor:
                                  //               Theme.of(context).dividerColor,
                                  //           highlightColor:
                                  //               Theme.of(context).buttonColor,
                                  //           child: SizedBox(
                                  //               height: 20,
                                  //               width: MediaQuery.of(context)
                                  //                       .size
                                  //                       .width /
                                  //                   2)),
                                  //     ])
                                  //   ],
                                  // );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          } else {
                            return Container(
                              height: MediaQuery.of(context).size.height / 1.4,
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.chat,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Your chat list is empty :(",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),

                  // FutureBuilder(
                  //     future: fetchChatList(),
                  //     builder: (context, snap) {
                  //       if (snap.connectionState == ConnectionState.waiting)
                  //         return Center(
                  //             child: CircularProgressIndicator(
                  //           strokeWidth: 2.0,
                  //         ));
                  //       else if (snap.hasData)
                  //         return ListView.builder(
                  //           shrinkWrap: true,
                  //           scrollDirection: Axis.vertical,
                  //           physics: NeverScrollableScrollPhysics(),
                  //           itemCount: snap.data != null ? snap.data.length : 0,
                  //           itemBuilder: (BuildContext context, int index) {
                  //             Match match = snap.data[index];
                  //             return MyConversationWidget(
                  //               user: match.user,
                  //               lastMessage: match.lastMessage,
                  //               chatId: match.chatId,
                  //               timestamp: match.timestamp,
                  //             );
                  //           },
                  //         );
                  //       else if (snap.hasError)
                  //         return Center(
                  //           child: Row(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: <Widget>[
                  //               Icon(
                  //                 Icons.face,
                  //                 color: Colors.grey,
                  //               ),
                  //               SizedBox(width: 10),
                  //               Text("You haven't started any conversations yet :(",
                  //                   style: GoogleFonts.quicksand(
                  //                     GoogleFonts.overpass: GoogleFonts.quicksand(
                  // fontFamily: Constants.fontFamily,
                  //                         fontSize: 14,
                  //                         fontWeight: FontWeight.w500,
                  //                         color: Colors.grey),
                  //                   )),
                  //             ],
                  //           ),
                  //         );
                  //       else
                  //         return Container(
                  //           height: MediaQuery.of(context).size.height / 1.4,
                  //           child: Center(
                  //             child: Row(
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: <Widget>[
                  //                 Icon(
                  //                   Icons.face,
                  //                   color: Colors.grey,
                  //                 ),
                  //                 SizedBox(width: 10),
                  //                 Text("You haven't started any conversations yet :(",
                  //                     style: GoogleFonts.quicksand(
                  //                       GoogleFonts.overpass: GoogleFonts.quicksand(
                  //   fontFamily: Constants.fontFamily,
                  //                           fontSize: 14,
                  //                           fontWeight: FontWeight.w500,
                  //                           color: Colors.grey),
                  //                     )),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //     }),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<PostUser>> users(List<Match> chats) async {
    List<PostUser> p = [];
    for (var chat in chats) {
      PostUser user = await getUser(chat.peerId);
      if (blockList.containsKey(user.id)) {
        // blocked
      } else {
        p.add(user);
      }
    }
    return p;
  }

  @override
  void initState() {
    super.initState();
    getBlocks().then((value) {
      setState(() {
        blockList = value;
        hasInitialized = true;
      });
      var uniKey = Constants.checkUniversity();
      var myID = firebaseAuth.currentUser.uid;
      db = db
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(myID)
          .child('chats');
      myStream = db.onValue;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
